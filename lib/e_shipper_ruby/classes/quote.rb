module EShipper
  class Quote < OpenStruct
    POSSIBLE_FIELDS = [:service_id, :service_name]
    REQUIRED_FIELDS = [:service_id, :service_name]
  end
end
