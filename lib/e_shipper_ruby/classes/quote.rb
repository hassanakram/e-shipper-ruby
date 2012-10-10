require 'nokogiri'

module EShipper
  class Quote < OpenStruct
    attr_accessor :surcharges

    POSSIBLE_FIELDS = [:carrier_id, :carrier_name, :service_id, :service_name,
      :transport_mode, :transit_days, :currency, :base_charge, :fuel_surcharge,
      :total_charge
    ]
    REQUIRED_FIELDS = []

    def initialize(attributes = {})
      @surcharges = []
      super attributes
    end

    def description type='light'
      rejected_attr = ('light' == type.to_s ? %w{carrier_id carrier_name service_id service_name} : [])
      doc = Nokogiri::HTML::DocumentFragment.parse ""
      Nokogiri::HTML::Builder.with(doc) do |doc|
        doc.div(:class => 'e_shipper_quote_description') do
          doc.ul do
            self.attributes.each do |attr|
              doc.li "#{attr[0]}: #{attr[1]}" unless rejected_attr.include?(attr[0]) || attr[1].empty?
            end
          end
        end
      end
      doc.to_html
    end
  end
end
