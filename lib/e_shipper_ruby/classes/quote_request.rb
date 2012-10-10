require 'nokogiri'
require 'builder'

module EShipper
	class QuoteRequest < EShipper::Request
		def request_body options
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

      request
		end

		def type
			'quote'
		end
	end
end