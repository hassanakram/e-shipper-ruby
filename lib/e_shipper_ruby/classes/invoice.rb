module EShipper
  class Invoice < EShipper::OpenStruct

    attr_accessor :items

    def initialize(attributes = {})
      @items = []
      super attributes
    end

    POSSIBLE_FIELDS = [ :broker_name, :contact_company, :name, 
      :contact_name, :contact_phone, :dutiable, :duty_tax_to
    ]

    REQUIRED_FIELDS = [:contact_name, :contact_phone]
  end
end
