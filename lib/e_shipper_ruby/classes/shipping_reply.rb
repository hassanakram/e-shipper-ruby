#NOTE: labels et custom invoices contains base-64 data to build PDF files 
module EShipper
  class ShippingReply < OpenStruct
  	attr_accessor :references, :package_tracking_numbers, :quote

    POSSIBLE_FIELDS = [:order_id, :carrier_name, :service_name, :tracking_url, :pickup_message, 
    	:pickup_confirmation_number, :labels, :customer_invoice
    ]
    REQUIRED_FIELDS = []

    def initialize(attributes = {})
       @references, @package_tracking_numbers, @quote = [], [], nil
       super attributes
    end

    def description
      attrs = self.attributes
      attrs.delete('labels')
      attrs.delete('customer_invoice')	
      
      rejected_attrs = %{carrier_id service_id currency} 

      doc = Nokogiri::HTML::DocumentFragment.parse ""
      Nokogiri::HTML::Builder.with(doc) do |doc|
		doc.div(:class => 'e_shipper_shipping_reply_description') do
		  doc.h2 'Shipping description'
		  doc.ul do
		    attrs.each do |attr|
			  doc.li "#{attr[0].label}: #{attr[1]}" if attr[1] && (!attr[1].empty?)
		    end
		  end
		  doc.div(:class => 'e_shipper_tracking_numbers') do
			doc.h2 "Tracking numbers"
			doc.ul do	
			  @package_tracking_numbers.each do |tracking_number|
			    doc.li "#{tracking_number}"
			  end
		    end
		  end
		  doc.div(:class => 'e_shipper_references') do
		  	doc.h2 "References"
		  	doc.ul do
			  @references.each do |reference|
			    doc.li do
			      doc.div(:class => 'e_shipper_reference_description') do
		            reference.attributes.each do |attr|
			          doc.span "#{attr[1].label}    " if attr[1] && (!attr[1].empty?)
		            end
		          end
			    end
			  end
		    end
		  end
		  doc.div(:class => 'e_shipper_quote_description') do
		    doc.h2 "Quote description"
		    doc.ul do
		      @quote.attributes.each do |attr|
		      	unless rejected_attrs.include?(attr[0]) || attr[1].empty?
		      	  if %{base_charge fuel_surcharge total_charge}.include?(attr[0])
		      	    doc.li "#{attr[0].label}: #{attr[1]}  $ CAD" 
		          else
			        doc.li "#{attr[0].label}: #{attr[1]}"
			      end
			    end
		      end
		    end
		  end
        end
      end
      doc.to_html
    end
  end
end