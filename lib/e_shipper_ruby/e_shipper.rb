require 'net/http'
require 'builder'

module EShipper

  def self.quote_request(options, url = 'http://test.eshipper.com/eshipper/rpc2')
    request = build_quote_request_body(options)
    puts request
    post(url, request)
  end

  def self.build_quote_request_body(options)
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

  def self.shipping_request(options, url = 'http://test.eshipper.com/eshipper/rpc2')
    request = build_shipping_request_body(options)
    puts request
    post(url, request)
  end

  def self.build_shipping_request_body(options)
    request = Builder::XmlMarkup.new(:indent=>2)
    request.instruct!
    request.EShipper(options[:EShipper], :xmlns=>"http://www.eshipper.net/XMLSchema") do |eshipper|
      eshipper.ShippingRequest(options[:QuoteRequest]) do |quote|
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
        quote.Payment(options[:Payment])
        unless options[:References].empty? then options[:References].each do |reference|
            quote.Reference(reference.attributes)
          end
        end
        if options[:CustomsInvoice] then quote.CustomsInvoice(options[:CustomsInvoice]) do |invoice|
            invoice.BillTo(options[:CustomsInvoice][:BillTo])
            invoice.Contact(options[:CustomsInvoice][:Contact])
            invoice.Item(options[:CustomsInvoice][:Item])
            if options[:DutiesTaxes] then invoice.DutiesTaxes(options[:CustomsInvoice][:DutiesTaxes]) end
          end
        end
      end
    end
  end

  def self.post(url, request_body)
    uri = URI(url)
    http_request = Net::HTTP::Post.new(uri.path)

    http_request.body = request_body

    http_response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(http_request)
    end
  end
end
