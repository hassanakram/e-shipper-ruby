require 'e_shipper_ruby/classes/open_struct'

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
