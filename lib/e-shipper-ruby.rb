require "e-shipper-ruby/version"
require 'net/http'
require 'builder'

module EShipperRuby
  def self.quote_request(options, packages, url = "http://test.eshipper.com/eshipper/rpc2")
    request = build_quote_request_body(options, packages)
    puts request
    post(url, request)
  end

  def self.build_quote_request_body(options, packages)
    builder = Builder::XmlMarkup.new
    builder.instruct!
    builder.EShipper(options[:EShipper]) do |eshipper|
      eshipper.QuoteRequest(options[:QuoteRequest]) do |quote|
        quote.From(options[:From])
        quote.To(options[:To])
        quote.COD(options[:COD]) do |cod|
          cod.CODReturnAddress(options[:CODReturnAddress])
        end
        quote.Packages(options[:Packages]) do |packs|
          packages.each do |package|
            packs.Package(package)
          end
        end
        quote.Pickup(options[:Pickup])
      end
    end
  end

  def self.shipping_request(options,packages,references,url = "")
    post(url, build_shipping_request_body(options,packages,references))
  end

  def self.build_shipping_request_body(options, packages, references)
    builder = Builder::XmlMarkup.new
    builder.instruct!
    builder.EShipper(options[:EShipper]) do |eshipper|
      eshipper.ShippingRequest(options[:QuoteRequest]) do |quote|
        quote.From(options[:From])
        quote.To(options[:To])
        quote.COD(options[:COD]) do |cod|
          cod.CODReturnAddress(options[:CODReturnAddress])
        end
        quote.Packages(options[:Packages]) do |packs|
          packages.each do |package|
            packs.Package(package)
          end
        end
        quote.Pickup(options[:Pickup])
        quote.Payment(options[:Payment])
        references.each do |reference|
          quote.Reference(reference)
        end
        quote.CustomsInvoice(options[:CustomsInvoice]) do |invoice|
          invoice.BillTo(options[:CustomsInvoice][:BillTo])
          invoice.Contact(options[:CustomsInvoice][:Contact])
          invoice.Item(options[:CustomsInvoice][:Item])
          invoice.DutiesTaxes(options[:CustomsInvoice][:DutiesTaxes])
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
