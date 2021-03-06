require 'rollbar'
begin
  require 'rack/mock'
rescue LoadError
end
require 'logger'

namespace :rollbar do
  desc 'Verify your gem installation by sending a test exception to Rollbar'
  task :test => [:environment] do
    class RollbarTestingException < RuntimeError;
    end

    unless Rollbar.configuration.access_token
      puts 'Rollbar needs an access token configured. Check the README for instructions.'

      exit
    end

    puts 'Testing manual report...'
    Rollbar.error('Test error from rollbar:test')

    # Module to inject into rack apps
    module RollbarTest
      def test_rollbar
        puts 'Raising RollbarTestingException to simulate app failure.'

        raise RollbarTestingException.new, 'Testing rollbar with "rake rollbar:test". If you can see this, it works.'
      end
    end

    if defined?(Rack::MockRequest)
      protocol = 'http'
      app      = Class.new do
        include RollbarTest

        def self.call(_env)
          new.test_rollbar
        end
      end

      puts 'Processing...'
      env     = Rack::MockRequest.env_for("#{protocol}://www.example.com/verify")
      status, = app.call(env)

      unless status.to_i == 500
        puts 'Test failed! You may have a configuration issue, or you could be using a gem that\'s blocking the test. Contact support@rollbar.com if you need help troubleshooting.'
      end
    end
  end
end
