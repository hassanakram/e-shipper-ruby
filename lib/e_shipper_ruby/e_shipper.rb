require 'net/http'
require 'builder'
require 'nokogiri'
require 'singleton'

module EShipper
  class Client
    include EShipper::ParsingHelpers
    include Singleton
    
    COMMON_REQUEST_OPTIONS = {:EShipper => {:version => "3.0.0"},
      :QuoteRequest => {:insuranceType => "Carrier"},
      :Packages => {:type => "Package"}
    }
    
    attr_reader :username, :password, :url, :from, :to, 
                :pickup, :packages, :references, :responses

    def initialize
      @options = 
      if defined?(Rails.env) 
        rails_config_path = Rails.root.join('config', 'e_shipper.yml')
        YAML.load_file(rails_config_path)[Rails.env] if File.exist?(rails_config_path)
      else
        gem_config_path = File.expand_path("#{File.dirname(__FILE__)}/../../conf/e_shipper.yml")
        YAML.load_file(gem_config_path)['production'] if File.exist?(gem_config_path)
      end
      @options.symbolize_keys!

      @username, @password, @url = @options[:username], @options[:password], @options[:url]
      
      raise 'No username specified.' if @username.nil? || @username.empty?
      raise 'No password specified.' if @password.nil? || @password.empty?
      if @url.nil? || @url.empty?
        @url = (defined?(Rails.env) && 'production' == Rails.env) ?
          'http://www.eshipper.com/rpc2' : 'http://test.eshipper.com/eshipper/rpc2'
      end

      @from = EShipper::Address.new @options[:from] if @options[:from]
      @packages, @references, @responses = [], [], []
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
      last_response.errors.empty? && (!last_response.xml.empty?)
    end

    def prepare_request!(*attrs_data) 
      from, to, pickup, packages, references = attrs_data
    
      @from = EShipper::Address.new(from).validate! if from
      @to = EShipper::Address.new(to).validate! if to
      @pickup = EShipper::Pickup.new(pickup).validate! if pickup

      if packages  
        packages.each do |package_data|
          @packages << EShipper::Package.new(package_data).validate!
        end
      end
 
      if references
        references.each do |reference_data|
          @references << EShipper::Reference.new(reference_data).validate!
        end
      end
    end

    private
    
    def send_request(options, type='quote')
      options[:EShipper][:username] = @username
      options[:EShipper][:password] = @password
      options[:From] = @from if @from
      options[:To] = @to if @to
      options[:Pickup] = @pickup if @pickup
      options[:PackagesList] = @packages if(@packages && !@packages.empty?)
      options[:References] = @references if(@references && !@references.empty?)
      options.symbolize_keys!

      request_body = send("build_#{type}_request_body", options)

      uri = URI(@url)
      http_request = Net::HTTP::Post.new(uri.path)
      http_request.body = request_body

      http_response = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(http_request)
      end
 
      @responses << EShipper::Response.new(type, http_response.body)
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
