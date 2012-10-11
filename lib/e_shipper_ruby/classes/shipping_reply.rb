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
		  doc.h2 'Shipping reply description'
		  doc.ul do
		    self.attributes.each do |attr|
			  doc.li "#{attr[0]}: #{attr[1]}" unless attr[1].empty?
		    end
		  end
		  doc.div(:class => 'e_shipper_tracking_numbers') do
			doc.h2 "Tracking numbers:"
			doc.ul do	
			  @package_tracking_numbers.each do |tracking_number|
			    doc.li "#{tracking_number}"
			  end
		    end
		  end
		  doc.div(:class => 'e_shipper_references') do
		  	doc.h2 "References:"
		  	doc.ul do
			  @references.each do |reference|
			    doc.li do
			      doc.div(:class => 'e_shipper_reference_description') do
			        doc.ul do
		              reference.attributes.each do |attr|
			            doc.li "#{attr[0]}: #{attr[1]}" unless attr[1].empty?
		              end
		            end
		          end
			    end
			  end
		    end
		  end
		  doc.div(:class => 'e_shipper_quote_description') do
		    doc.h2 "Quote description:"
		    doc.ul do
		      @quote.attributes.each do |attr|
			    doc.li "#{attr[0]}: #{attr[1]}" unless attr[1].empty?
		      end
		    end
		  end
        end
      end
      doc.to_html
    end
  
  end
end