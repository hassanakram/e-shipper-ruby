require 'nokogiri'
require 'builder'

module EShipper
	class ShippingRequest < EShipper::Request
		def request_body options
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
      request	
		end

		def type
			'shipping'
		end
	end
end