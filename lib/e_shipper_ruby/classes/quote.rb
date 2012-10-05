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
  end
end
