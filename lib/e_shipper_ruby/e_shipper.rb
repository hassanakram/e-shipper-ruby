require 'net/http'
require 'builder'
require 'nokogiri'

module EShipper
  class Client
    attr_accessor :username, :password, :url, :from, :to, :pickup, :packages, :references

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
      self.from = EShipper::Address.new @options[:from] if @options[:from]
      self.packages, self.references = [], []

      raise 'No username specified.' if self.username.nil? || self.username.empty?
      raise 'No password specified.' if self.password.nil? || self.password.empty?
      if self.url.nil? || self.url.empty?
        self.url = (defined?(Rails.env) && 'production' == Rails.env) ?
          'http://www.eshipper.com/rpc2' : 'http://test.eshipper.com/eshipper/rpc2'
      end
    end

    #TODO: complete data parsing  
    def parse_quotes options
      result = []
      xml_data = send_request options
      xml_data.css('Quote').each do |quote|
        data = { :service_id => quote.attributes['serviceId'].content, :service_name => quote.attributes['serviceName'].content }
        result << EShipper::Quote.new(data)
      end
      result
    end

    #TODO: complete data parsing  
    def parse_shipping options
      result = []
      xml_data = send_request options, 'shipping'
      result
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
