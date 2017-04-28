module NotifierHelpers
  def reconfigure_notifier
    Rollbar.clear_notifier!

    Rollbar.reconfigure do |config|
      # special test access token
      config.access_token = test_access_token
      config.logger = Logger.new(STDERR)
      config.root = nil
      config.framework = "banana"
      config.open_timeout = 60
      config.request_timeout = 60
    end
  end

  def test_access_token
    'bfec94a1ede64984b862880224edd0ed'
  end

  def reset_configuration
    Rollbar.reconfigure do |config|
    end
  end
end
