require 'e_shipper_ruby/classes/open_struct'

class Package < OpenStruct
  POSSIBLE_FIELDS = [
    :length, :width, :height, :weight,
    :type, #Required if type="Pallet"
    :freightClass, #Required if type="Pallet"
    :nmfcCode, #Required if type="Pallet"
    :insuranceAmount, :codAmount,
    :description #Required if type="Pallet"
  ]

  REQUIRED_FIELDS = [
    :length, :width, :height, :weight, :insuranceAmount, :codAmount
  ]

end
