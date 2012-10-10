module EShipper
  class ShippingReply < OpenStruct
  	attr_accessor :references, :package_tracking_numbers, :quote

    POSSIBLE_FIELDS = [:order_id, :carrier_name, :service_name, :tracking_url, :pickup_message]
    REQUIRED_FIELDS = []

    def initialize(attributes = {})
       @references, @package_tracking_numbers, @quote = [], [], nil
       super attributes
    end

    def description
      doc = Nokogiri::HTML::DocumentFragment.parse ""
      Nokogiri::HTML::Builder.with(doc) do |doc|
		doc.div(:class => 'e_shipper_shipping_reply_description') do
		  doc.h2 'Shippin reply description'
		  doc.ul do
		    self.attributes.each do |attr|
			  doc.li "#{attr[0]}: #{attr[1]}" unless attr[1].empty?
		    end
		  end
		  doc.div(:class => 'e_shipper_tracking_numbers') do
			doc.h2 "Tracking numbers:"	
			@package_tracking_numbers.each do |tracking_number|
			  doc.span "#{tracking_number}"
			end
		  end
		  doc.div(:class => 'e_shipper_references') do
			@references.each do |reference|
			  doc.span reference.description	
			end
		  end
		  doc.div @quote.description(:complete)
        end
      end
      doc.to_html
    end
  
  end
end