require 'e_shipper_ruby/version'
require 'e_shipper_ruby/configuration'
require 'e_shipper_ruby/e_shipper'

module EShipperRuby

  # Gives access to the current Configuration.
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Allows easy setting of multiple configuration options. See Configuration
  # for all available options.
  def self.configure
    config = configuration
    yield(config)
  end

  def self.with_configuration(config)
    original_config = {}

    config.each do |key, value|
      original_config[key] = configuration.send(key)
      configuration.send("#{key}=", value)
    end

    result = yield if block_given?

    original_config.each { |key, value| configuration.send("#{key}=", value) }
    result
  end

  class EShipperRubyError < StandardError
  end
end

# If we are using Rails then we will include the EShipperRuby railtie.
if defined?(Rails)
  require 'e_shipper_ruby/railtie'
end
