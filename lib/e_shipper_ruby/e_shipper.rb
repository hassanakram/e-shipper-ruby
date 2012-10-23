require 'net/http'
require 'nokogiri'
require 'singleton'

module EShipper
  class Client
    include EShipper::ParsingHelpers
    include Singleton
    
    attr_reader :username, :password, :url, :responses

    def initialize
      @options = 
      if defined?(Rails.env) 
        rails_config_path = Rails.root.join('config', 'e_shipper.yml')
        YAML.load_file(rails_config_path)[Rails.env] if File.exist?(rails_config_path)
      else
        gem_config_path = File.expand_path("#{File.dirname(__FILE__)}/../../config/e_shipper.yml")
        YAML.load_file(gem_config_path) if File.exist?(gem_config_path)
      end
      @options.symbolize_keys!

      @username, @password, @url, @responses = @options[:username], @options[:password], @options[:url], []
      
      raise 'No username specified.' if @username.nil? || @username.empty?
      raise 'No password specified.' if @password.nil? || @password.empty?
      if @url.nil? || @url.empty?
        @url = (defined?(Rails.env) && 'production' == Rails.env) ?
          'http://www.e-shipper.net/rpc2' : 'http://test.eshipper.com/eshipper/rpc2'
      end
    end

    def parse_quotes(options={})
      result = []
      request = EShipper::QuoteRequest.new
      request.prepare! options
      
      response = request.send_now
      @responses << EShipper::Response.new(:quote, response) 

      xml_data = Nokogiri::XML(response)
      error_messages xml_data
      
      quotes = xml_data.css('Quote')
      unless quotes.empty?
        quotes.each do |xml_quote|
          keys = [:carrier_id, :carrier_name, :service_id, :service_name,
           :transport_mode, :transit_days, :currency, :base_charge,
           :fuel_surcharge, :total_charge
          ]
          quote = EShipper::Quote.new(data(xml_quote, keys))
          surcharges = xml_quote.css('Surcharge')
          unless surcharges.empty?
            surcharges.each do |xml_surcharge|
              keys = [:id, :name, :amount]
              quote.surcharges << EShipper::Surcharge.new(data(xml_surcharge, keys))
            end
          end
          result << quote
        end
      end      
      result
    end

    def parse_shipping(options={})
      shipping_reply = nil

      request = EShipper::ShippingRequest.new
      request.prepare! options
      response = request.send_now
      @responses << EShipper::Response.new(:shipping, response) 

      xml_data = Nokogiri::XML(response)
      error_messages xml_data
   
      shipping_replies = xml_data.css('ShippingReply')
      unless shipping_replies.empty?
        data = { :order_id => try_direct_extract(xml_data, 'Order', 'id'), 
          :carrier_name => try_direct_extract(xml_data, 'Carrier', 'carrierName'), 
          :service_name => try_direct_extract(xml_data, 'Carrier', 'serviceName'), 
          :tracking_url => try_direct_extract(xml_data, 'TrackingURL'), 
          :pickup_confirmation_number => try_direct_extract(xml_data, 'Pickup', 'confirmationNumber'),
          :pickup_message => try_direct_extract(xml_data, 'Pickup', 'errorMessage'),
          :labels => try_direct_extract(xml_data, 'Labels'),
          :customer_invoice => try_direct_extract(xml_data, 'CustomsInvoice') 
        }
        shipping_reply = EShipper::ShippingReply.new(data)
        
        packages = xml_data.css('Package')
        unless packages.empty?
          packages.each do |xml_package|
           shipping_reply.package_tracking_numbers << try_extract(xml_package, 'trackingNumber')
          end
        end
        
        references = xml_data.css('Reference')
        unless references.empty?
          references.each do |xml_reference|
            keys = [:name, :code]
            shipping_reply.references << EShipper::Reference.new(data(xml_reference, keys))
          end
        end
       
        xml_quote = xml_data.css('Quote')[0]
        keys = [:carrier_id, :carrier_name, :service_id, :service_name,
          :transport_mode, :transit_days, :currency, :base_charge,
          :fuel_surcharge, :total_charge
        ] 
        quote = EShipper::Quote.new(data(xml_quote, keys))
         
        surcharges = xml_quote.css('Surcharge')
        unless surcharges.empty?
          surcharges.each do |xml_surcharge|
            keys = [:id, :name, :amount]
            quote.surcharges << EShipper::Surcharge.new(data(xml_surcharge, keys))
          end
        end
        shipping_reply.quote = quote
      end
      shipping_reply
    end

    def last_response
      responses.last
    end

    def validate_last_response
      last_response.errors.empty? && (!last_response.xml.empty?)
    end
  end
end
