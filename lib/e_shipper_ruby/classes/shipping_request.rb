module EShipper
  class ShippingRequest < EShipper::Request

    def request_body
      client = EShipper::Client.instance
      options = COMMON_REQUEST_OPTIONS
      options[:ShippingRequest].merge!(@options) if @options
      options[:ShippingRequest].merge!(:serviceId => @service_id) if @service_id

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.EShipper(:version => "3.0.0", :xmlns => "http://www.eshipper.net/XMLSchema", 
            :username => client.username, :password => client.password) do
          
          xml.ShippingRequest(options[:ShippingRequest]) do 

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
            xml.Payment(options[:Payment])
            
            unless @references.empty?
              @references.each do |reference|
                xml.Reference(reference.attributes)
              end
            end

            if @invoice
              bill_to = @to.attributes.merge!(:name => @pickup[:contactName])

              xml.CustomsInvoice('brokerName' => @invoice.broker_name,
                'contactCompany' => @invoice.contact_company,
                'contactName' => @invoice.contact_name) do

                xml.BillTo(bill_to) if @to
                xml.Contact(:name => @invoice.contact_name, :phone => @invoice.contact_phone)
                @invoice.items.each do |item|
                  xml.Item(item.attributes)
                end
                xml.DutiesTaxes(:dutiable => @invoice.dutiable, :billTo => @invoice.duty_tax_to)
              end
            end
          end
        end
      end
      builder.to_xml
    end
  end
end
