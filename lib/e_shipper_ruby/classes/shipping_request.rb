module EShipper
	class ShippingRequest < EShipper::Request

		def request_body
      client = EShipper::Client.instance
      options = COMMON_REQUEST_OPTIONS
      options[:ShippingRequest].merge!(:serviceId => @service_id) if @service_id

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.EShipper(:version => "3.0.0", :xmlns => "http://www.eshipper.net/XMLSchema", 
            :username => client.username, :password => client.password) do
          
          xml.ShippingRequest(options[:ShippingRequest]) do 

            xml.From(@from.attributes) if @from
            xml.To(@to.attributes) if @to
            
            unless @packages.empty?
              xml.Packages(options[:Packages]) do
                @packages.each do |package|
                  xml.Package(package.attributes)
                end
              end
            end
          
            xml.Pickup(@pickup.attributes) if @pickup
            xml.Payment(options[:Payment])
            
            unless @references.empty?
              @references.each do |reference|
                xml.Reference(reference.attributes)
              end
            end
          end
        end
      end
      builder.to_xml
		end
	end
end