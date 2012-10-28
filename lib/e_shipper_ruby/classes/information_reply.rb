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
  end
end