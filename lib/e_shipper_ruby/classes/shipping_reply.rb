require 'nokogiri'

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
      	self.attributes.each do |attr|
          doc.p "#{attr[0]}: #{attr[1]}" unless attr[1].empty?
        end
        doc.div do
          doc.h2 "Tracking numbers:"	
          @package_tracking_numbers.each do |tracking_number|
	        doc.span "#{tracking_number}"
          end
        end
        doc.div do
	      @references.each do |reference|
	        doc.p reference.description	
	      end
        end
        doc.div @quote.description(:complete)
      end
      doc.to_html
    end
  end
end