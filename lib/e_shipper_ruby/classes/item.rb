module EShipper
  class Item < EShipper::OpenStruct

    POSSIBLE_FIELDS = [:code, :description, :originCountry, :quantity, :unitPrice]

    REQUIRED_FIELDS = POSSIBLE_FIELDS
  end
end
