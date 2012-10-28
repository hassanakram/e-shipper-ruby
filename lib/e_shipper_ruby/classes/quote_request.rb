module EShipper
  class QuoteRequest < EShipper::Request
		
    def request_body
      client = EShipper::Client.instance
      options = COMMON_REQUEST_OPTIONS
      options[:QuoteRequest].merge!(@options) if @options
      options[:QuoteRequest].merge!(:serviceId => @service_id) if @service_id

	  builder = Nokogiri::XML::Builder.new do |xml|
        xml.EShipper(:version => "3.0.0", :xmlns => "http://www.eshipper.net/XMLSchema", 
            :username => client.username, :password => client.password) do
          
          xml.QuoteRequest(options[:QuoteRequest]) do 
            
            xml.From(@from.attributes) if @from
            xml.To(@to.attributes) if @to
          
            if @cod
              xml.COD(:paymentType => @cod.payment_type) do
				xml.CODReturnAddress(@cod.return_address)
              end
            end
            
            unless @packages.empty?
              xml.Packages(options[:Packages]) do
                @packages.each do |package|
                  xml.Package(package.attributes)
                end
              end
            end
          
            xml.Pickup(@pickup.attributes) if @pickup
          end
        end
      end		
      builder.to_xml
    end
  end
end