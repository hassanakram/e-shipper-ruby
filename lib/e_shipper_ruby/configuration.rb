module EShipperRuby

  class Configuration
    attr_accessor :username,
                  :password,
                  :server_url

    def initialize #:nodoc:
      @username   = ENV['ESHIPPER_USERNAME']
      @password   = ENV['ESHIPPER_PASSWORD']
      @server_url = ENV['ESHIPPER_SERVER_URL']
    end
  end
end
