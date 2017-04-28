begin
  require 'simplecov'
  require 'codeclimate-test-reporter'

  SimpleCov.start do
    add_filter '/spec/'

    formatter SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::HTMLFormatter,
      CodeClimate::TestReporter::Formatter
    ])
  end
rescue LoadError
end

require 'rubygems'

ENV['RACK_ENV'] = 'test'

require 'database_cleaner'

begin
  require 'webmock/rspec'
  WebMock.disable_net_connect!(:allow => 'codeclimate.com')
rescue LoadError
end


if ENV['TRAVIS_JDK_VERSION'] == 'oraclejdk7'
  require 'rollbar/configuration'
  Rollbar::Configuration::DEFAULT_ENDPOINT = 'https://api-alt.rollbar.com/api/1/item/'
end


Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.extend(Helpers)
  config.include(NotifierHelpers)
  config.include(FixtureHelpers)
  config.include(EncodingHelpers)

  config.color = true
  config.formatter = 'documentation'


  config.order = 'random'
  config.expect_with(:rspec) do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = [:should, :expect]
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
    DatabaseCleaner.clean
    Rollbar.clear_notifier!

    stub_request(:any, /api.rollbar.com/).to_rack(RollbarAPI.new) if defined?(WebMock)
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location! if config.respond_to?(:infer_spec_type_from_file_location!)
  config.backtrace_exclusion_patterns = [/gems\/rspec-.*/]
end
