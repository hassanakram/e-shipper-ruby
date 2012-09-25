module EShipperRuby
  # This class constructs the username and password for the e-shipper API call.
  #
  # By calling
  #
  # EShipperRuby.configuration # => instance of EShipperRuby::Configuration
  #
  # or
  # EShipperRuby.configure do |config|
  # config # => instance of EShipperRuby::Configuration
  # end
  #
  # you are able to perform credentials configuration.
  #
  # Setting the keys with this Configuration
  #
  # EShipperRuby.configure do |config|
  # config.username = 'demo'
  # config.password = 'demo'
  # end
  #
  class Configuration
    attr_accessor :username,
                  :password

    def initialize
      @username   = ENV['ESHIPPER_USERNAME']
      @password   = ENV['ESHIPPER_PASSWORD']
    end
  end
end
