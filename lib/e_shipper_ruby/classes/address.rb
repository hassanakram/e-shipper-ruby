class Address < OpenStruct

  POSSIBLE_FIELDS = [
    :id, :company, :address1,
    :address2, #optional
    :city, :state,
    :country, :zip,
    :residential, #optional
    :tailgateRequired, #optional
    :phone, #optional for Quote, required for Shipping
    :attention, #optional for Quote, required for Shipping
    :email, #optional for Quote, required for Shipping
    :instructions, #optional
    :notifyRecipient #optional
  ]

  REQUIRED_FIELDS = [
    :id, :company, :address1, :address2, :city,
    :state, :country, :zip, :phone, :attention, :email
  ]

end
