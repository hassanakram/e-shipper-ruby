module EShipper
  class Pickup < OpenStruct

    POSSIBLE_FIELDS = [
      :contactName, :phoneNumber, :pickupDate,
      :pickupTime, :closingTime, :location
    ]

    REQUIRED_FIELDS = [
      :contactName, :phoneNumber, :pickupDate,
      :pickupTime, :closingTime
    ]
  end
end
