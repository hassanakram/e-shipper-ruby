module EShipper
  class Cod < EShipper::OpenStruct
    attr_accessor :address

    POSSIBLE_FIELDS = [:payment_type] 
    REQUIRED_FIELDS = POSSIBLE_FIELDS
      
    def initialize attrs
      @address = EShipper::Address.new(attrs.delete(:address)) if attrs[:address]  
      super
    end
    
    def validate!
      raise ArgumentError, "address is required" unless @address
      @address.validate!
      super
    end
    
    def return_address
      { :codCompany => @address.company, :codName => @address.attention,
        :codAddress1 => @address.address1, :codCity => @address.city,
        :codStateCode => @address.state, :codZip => @address.zip,
        :codCountry => @address.country }
    end
  end
end