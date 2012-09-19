require 'e_shipper_ruby/classes/open_struct'

class Reference < OpenStruct

  POSSIBLE_FIELDS = [
    :name, :code
  ]

  REQUIRED_FIELDS = POSSIBLE_FIELDS

end
