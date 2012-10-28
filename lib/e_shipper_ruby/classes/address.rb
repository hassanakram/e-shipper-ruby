module EShipper
  class Address < EShipper::OpenStruct

    POSSIBLE_FIELDS = [
      :id, :company, :address1, :address2, 
      :city, :state, :country, :zip,
      :residential, :tailgateRequired, :phone,
      :attention, :email, :instructions, :confirmDelivery,
      :notifyRecipient
    ]

    REQUIRED_FIELDS = [
      :id, :company, :address1, :city, :state, 
      :country, :zip, :phone, :attention, :email
    ]
  end
end
