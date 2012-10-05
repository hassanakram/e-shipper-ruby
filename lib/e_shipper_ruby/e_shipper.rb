require 'net/http'
require 'builder'
require 'nokogiri'

module EShipper
  class Client
    attr_accessor :username, :password, :url, :from, :to, 
                  :pickup, :packages, :references, :responses

    def initialize(options = {})
      @options = 
      case options
      when {} 
        if defined?(Rails.env) 
          rails_config_path = Rails.root.join('config', 'e_shipper.yml')
          YAML.load_file(rails_config_path)[Rails.env] if File.exist?(rails_config_path)
        end
      when String
        YAML.load_file(options) if File.exist?(options)
      else
        options
      end.symbolize_keys!

      self.username = ENV['E_SHIPPER_USERNAME'] || @options[:username]
      self.password = ENV['E_SHIPPER_PASSWORD'] || @options[:password]
      self.url      = ENV['E_SHIPPER_URL']      || @options[:url]
      
      raise 'No username specified.' if self.username.nil? || self.username.empty?
      raise 'No password specified.' if self.password.nil? || self.password.empty?
      if self.url.nil? || self.url.empty?
        self.url = (defined?(Rails.env) && 'production' == Rails.env) ?
          'http://www.eshipper.com/rpc2' : 'http://test.eshipper.com/eshipper/rpc2'
      end

      self.from = EShipper::Address.new @options[:from] if @options[:from]
      self.packages, self.references, self.responses = [], [], []
    end

    def parse_quotes options
      result, errors = [], { :errors => [] }
      xml_data = send_request options

      xml_errors = xml_data.css('Error')
      xml_errors.each do |xml_error|
        errors[:errors] << xml_error.attributes['Message'].content
      end
      return errors unless xml_errors.empty?

      xml_data.css('Quote').each do |xml_quote|
        data = { :carrier_id => xml_quote.attributes['carrierId'].content,
          :carrier_name => xml_quote.attributes['carrierName'].content,
          :service_id => xml_quote.attributes['serviceId'].content, 
          :service_name => xml_quote.attributes['serviceName'].content,
          :transport_mode => xml_quote.attributes['serviceName'].content,
          :transit_days => xml_quote.attributes['transitDays'].content,
          :currency => xml_quote.attributes['currency'].content,
          :base_charge => xml_quote.attributes['baseCharge'].content,
          :fuel_surcharge => xml_quote.attributes['fuelSurcharge'].content,
          :total_charge => xml_quote.attributes['totalCharge'].content
        }
        quote = EShipper::Quote.new(data)
        xml_quote.css('Surcharge').each do |xml_surcharge|
          data = { :id => xml_surcharge.attributes['id'].content, 
            :name => xml_surcharge.attributes['name'].content,
            :amount => xml_surcharge.attributes['amount'].content
          }
          quote.surcharges << EShipper::Surcharge.new(data) 
        end
        result << quote
      end
      result
    end

    def parse_shipping options
      errors = { :errors => [] }
      xml_data = send_request options, 'shipping'

      xml_errors = xml_data.css('Error')
      xml_errors.each do |xml_error|
        errors[:errors] << xml_error.attributes['Message'].content
      end
      return errors unless xml_errors.empty?

      xml_data = xml_data.css('ShippingReply')
      data = { :order_id => xml_data.css('Order')[0]['id'], 
        :carrier_name => xml_data.css('Carrier')[0]['carrierName'], 
        :service_name => xml_data.css('Carrier')[0]['serviceName'], 
        :tracking_url => xml_data.css('TrackingURL')[0].content, 
        :pickup_message => xml_data.css('Pickup')[0]['errorMessage']
      }
      shipping_reply = EShipper::ShippingReply.new(data)
      xml_data.css('Package').each do |xml_package|
        shipping_reply.package_tracking_numbers << xml_package.attributes['trackingNumber'].content
      end
      xml_data.css('Reference').each do |xml_reference|
        data = { :name => xml_reference.attributes['name'].content, :code => xml_reference.attributes['code'].content }
        reference = EShipper::Reference.new(data)
        shipping_reply.references << reference
      end
      xml_quote = xml_data.css('Quote')[0]
      data = {:carrier_id => xml_quote['carrierId'],
        :carrier_name => xml_quote['carrierName'],
        :service_id => xml_quote['serviceId'], 
        :service_name => xml_quote['serviceName'],
        :transport_mode => xml_quote['serviceName'],
        :transit_days => xml_quote['transitDays'],
        :currency => xml_quote['currency'],
        :base_charge => xml_quote['baseCharge'],
        :fuel_surcharge => xml_quote['fuelSurcharge'],
        :total_charge => xml_quote['totalCharge']
      }
      quote = EShipper::Quote.new(data)
      xml_quote.css('Surcharge').each do |xml_surcharge|
        data = { :id => xml_surcharge.attributes['id'].content, 
          :name => xml_surcharge.attributes['name'].content,
          :amount => xml_surcharge.attributes['amount'].content
        }
        quote.surcharges << EShipper::Surcharge.new(data) 
      end
      shipping_reply.quote = quote
      shipping_reply
    end

    private

    def send_request(options, type = 'quote')
      options[:EShipper][:username] = self.username
      options[:EShipper][:password] = self.password
      options[:From] = self.from if self.from
      options[:To] = self.to if self.to
      options[:Pickup] = self.pickup if self.pickup
      options[:PackagesList] = self.packages if self.packages
      options[:References] = self.references if self.references
      options.symbolize_keys!

      request_body = send("build_#{type}_request_body", options)

      uri = URI(self.url)
      http_request = Net::HTTP::Post.new(uri.path)

      http_request.body = request_body

      http_response = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(http_request)
      end

      self.responses << EShipper::Response.new(type, http_response.body)
      Nokogiri::XML(http_response.body)
    end

    def build_quote_request_body(options)
      request = Builder::XmlMarkup.new(:indent=>2)
      request.instruct!
      request.EShipper(options[:EShipper], :xmlns=>"http://www.eshipper.net/XMLSchema") do |eshipper|
        eshipper.QuoteRequest(options[:QuoteRequest]) do |quote|
          quote.From(options[:From].attributes)
          quote.To(options[:To].attributes)
          if options[:COD] then quote.COD(options[:COD]) do |cod|
              cod.CODReturnAddress(options[:CODReturnAddress])
            end
          end
          quote.Packages(options[:Packages]) do |packs|
            options[:PackagesList].each do |package|
              packs.Package(package.attributes)
            end
          end
          if options[:Pickup] then quote.Pickup(options[:Pickup].attributes) end
        end
      end
    end

    def build_shipping_request_body(options)
      request = Builder::XmlMarkup.new(:indent=>2)
      request.instruct!
      request.EShipper(options[:EShipper], :xmlns=>"http://www.eshipper.net/XMLSchema") do |eshipper|
        eshipper.ShippingRequest(options[:QuoteRequest]) do |shipping|
          shipping.From(options[:From].attributes)
          shipping.To(options[:To].attributes)
          if options[:COD] then shipping.COD(options[:COD]) do |cod|
              cod.CODReturnAddress(options[:CODReturnAddress])
            end
          end
          shipping.Packages(options[:Packages]) do |packs|
            options[:PackagesList].each do |package|
              packs.Package(package.attributes)
            end
          end
          if options[:Pickup] then shipping.Pickup(options[:Pickup].attributes) end
          shipping.Payment(options[:Payment])
          unless options[:References].empty? then options[:References].each do |reference|
              shipping.Reference(reference.attributes)
            end
          end
          if options[:CustomsInvoice] then shipping.CustomsInvoice(options[:CustomsInvoice]) do |invoice|
              invoice.BillTo(options[:CustomsInvoice][:BillTo])
              invoice.Contact(options[:CustomsInvoice][:Contact])
              invoice.Item(options[:CustomsInvoice][:Item])
              if options[:DutiesTaxes] then invoice.DutiesTaxes(options[:CustomsInvoice][:DutiesTaxes]) end
            end
          end
        end
      end
    end
  end
end
