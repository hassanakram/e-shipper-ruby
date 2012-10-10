require 'nokogiri'

module EShipper
  class Reference < OpenStruct
    
    POSSIBLE_FIELDS = [:name, :code]
    REQUIRED_FIELDS = [:name, :code]
  end
end
