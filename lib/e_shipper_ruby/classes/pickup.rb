module EShipper
  class Pickup < OpenStruct

    POSSIBLE_FIELDS = [
      :contactName, :phoneNumber, :pickupDate,
      :pickupTime, :closingTime, :location
    ]

    REQUIRED_FIELDS = POSSIBLE_FIELDS
  end
end
