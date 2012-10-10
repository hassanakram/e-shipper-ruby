module EShipper
  class Package < OpenStruct

    POSSIBLE_FIELDS = [
      :length, :width, :height, :weight,
      :type, :freightClass, :nmfcCode, :insuranceAmount, 
      :codAmount, :description
    ]

    REQUIRED_FIELDS = [ :length, :width, :height, :weight ]
  end
end
