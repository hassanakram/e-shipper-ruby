require 'nokogiri'

module EShipper
  class Reference < OpenStruct

    POSSIBLE_FIELDS = [:name, :code]

    REQUIRED_FIELDS = POSSIBLE_FIELDS
    
    def description
      doc = Nokogiri::HTML::DocumentFragment.parse ""
      Nokogiri::HTML::Builder.with(doc) do |doc|
        self.attributes.each do |attr|
          doc.p "#{attr[0]}: #{attr[1]}" unless attr[1].empty?
        end
      end
      doc.to_html
    end
  end
end
