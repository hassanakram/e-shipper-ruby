require 'net/http'
require 'builder'
require 'nokogiri'

module EShipper
  class Client
    include EShipper::ParsingHelpers
    
    COMMON_REQUEST_OPTIONS = {:EShipper => {:version => "3.0.0"},
      :QuoteRequest => {:insuranceType => "Carrier"},
      :Packages => {:type => "Package"}
    }
    
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

    def parse_quotes(options=COMMON_REQUEST_OPTIONS)
      result = []
      xml_data = send_request options

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
      result.sort_by(&:total_charge)
    end

    def parse_shipping(options=COMMON_REQUEST_OPTIONS)
      shipping_reply = nil
      xml_data = send_request options, 'shipping'

      error_messages xml_data
   
      shipping_replies = xml_data.css('ShippingReply')
      unless shipping_replies.empty?
        data = { :order_id => try_direct_extract(xml_data, 'Order', 'id'), 
          :carrier_name => try_direct_extract(xml_data, 'Carrier', 'carrierName'), 
          :service_name => try_direct_extract(xml_data, 'Carrier', 'serviceName'), 
          :tracking_url => try_direct_extract(xml_data, 'TrackingURL'), 
          :pickup_message => try_direct_extract(xml_data, 'Pickup', 'errorMessage')
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
      last_response.errors.empty?
    end

    def prepare_request(from, to, pickup, packages, references)
      self.from = EShipper::Address.new(from) if from
      self.to = EShipper::Address.new(to) if to
      self.pickup = EShipper::Pickup.new(pickup) if pickup

      if packages  
        packages.each do |package_data|
          self.packages << EShipper::Package.new(package_data)
        end
      end
 
      if references
        references.each do |reference_data|
          self.references << EShipper::Reference.new(reference_data)
        end
      end
    end

    private
    
    def send_request(options, type='quote')
      options[:EShipper][:username] = self.username
      options[:EShipper][:password] = self.password
      options[:From] = self.from if self.from
      options[:To] = self.to if self.to
      options[:Pickup] = self.pickup if self.pickup
      options[:PackagesList] = self.packages if(self.packages && !self.packages.empty?)
      options[:References] = self.references if(self.references && !self.references.empty?)
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
    rescue NoMethodError
      raise "Verify that the mandatory data 'from', 'to', 'packages' are set on the client or in the request options"
    end

    #NOTE: requests generators
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
