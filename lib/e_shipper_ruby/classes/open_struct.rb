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
      raise ArgumentError, "#{k} is required for #{self.class.name} type" unless self.class::REQUIRED_FIELDS.include?(k.to_sym)
    end
    return true
  end
end
