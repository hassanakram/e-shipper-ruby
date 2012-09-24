require 'test/unit'
require 'e_shipper_ruby/classes/address'

class AddressTest  < Test::Unit::TestCase

  def test_valid_address
    address = Address.new({:id => "123", :company=>"Vitamonthly", :address1=>"650 CIT Drive", :address2=>"Apt B-2",
      :city=>"Livingston", :state=>"ON", :zip=>"L4J7Y9", :country=>"CA", :phone=>"888-888-8888",
      :attention => "Vitamonthly", :email => "eshipper@vitamonthly.com"})

    assert address.validate!
    assert_equal "Vitamonthly", address.company
    assert_equal "eshipper@vitamonthly.com", address.email
  end

  def test_invalid_address
    address1 = Address.new
    assert_raise(ArgumentError) { address1.validate! }

    address2 = Address.new({:invalid => "invalid"})
    assert_raise(ArgumentError) { address2.validate! }
  end
end
