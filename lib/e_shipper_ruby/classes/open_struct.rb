module EShipper
  class OpenStruct
    attr_reader :attributes

    def initialize(attributes = {})
      @attributes = {}
      attributes.each { |k, v| send("#{k}=", v) }
    end

    def method_missing(name, *args)
      attribute = name.to_s
      if attribute =~ /=$/
        @attributes[attribute.strip.chop] = args[0]
      else
        @attributes[attribute.strip]
      end
    end

    def validate!
      raise ArgumentError, "#{self.class::REQUIRED_FIELDS.join(', ')} are required" if @attributes.empty?
      @attributes.each do |k, v|
        raise ArgumentError, "#{k} is not a valid #{self.class.name} field" unless self.class::POSSIBLE_FIELDS.include?(k.to_sym)
      end
      self.class::REQUIRED_FIELDS.each do |k|
        raise ArgumentError, "#{k} is required for #{self.class.name} type" unless @attributes.has_key?(k.to_s)
        raise ArgumentError, "#{k} cannot be nil for #{self.class.name} type" if @attributes[k.to_s].nil?
      end
      self
    end
    
    def description
      doc = Nokogiri::HTML::DocumentFragment.parse ""
      Nokogiri::HTML::Builder.with(doc) do |doc|
        doc.div(:class => "e_shipper_#{class_name.downcase}_description") do
          doc.h2 "#{class_name} description"
          doc.ul do
            self.attributes.each do |attr|
              doc.li "#{attr[0]}: #{attr[1]}" if attr[1] && (!attr[1].empty?)
            end
          end
        end
      end
      doc.to_html
    end
    
    def class_name
      self.class.to_s.split('::').last
    end
  end
end
