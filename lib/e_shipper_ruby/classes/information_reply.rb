module EShipper
  class InformationReply < OpenStruct
    attr_accessor :history
  
    POSSIBLE_FIELDS = [:order_id, :status, :carrier, :service, :shipment_date]
    REQUIRED_FIELDS = POSSIBLE_FIELDS 
    
    def initialize(attrs={})
      @history = []
      date = attrs.delete(:shipment_date) if attrs[:shipment_date]
      super
      self.shipment_date = Time.new(date) if date
    end

    def history_description
      doc = Nokogiri::HTML::DocumentFragment.parse ""
      Nokogiri::HTML::Builder.with(doc) do |doc|
        doc.div(:class => 'e_shipper_history_description') do
          doc.h2 "History"
          doc.div(:class => 'e_shipper_history', :style => 'margin-top:20px') do
            history.each do |status|
              doc.ul do
                status.attributes.each do |attr|
                  doc.li "#{attr[0].label}: #{attr[1]}" if attr[1] && (!attr[1].empty?)
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