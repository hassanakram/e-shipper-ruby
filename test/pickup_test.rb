require 'test/unit'
require 'e_shipper_ruby/classes/pickup'

class PickupTest  < Test::Unit::TestCase

  def test_valid_package
    t = Time.now + 5 * 24 * 60 * 60 # 5 days from now

    pickup = Pickup.new({:contactName => "Test Name", :phoneNumber => "888-888-8888", :location => "Front Door",
      :pickupDate => t.strftime("%Y-%m-%d"), :pickupTime => t.strftime("%H:%M"),
      :closingTime => (t+2*60*60).strftime("%H:%M")})

    assert pickup.validate!
    assert_equal "Front Door", pickup.location
    assert_equal "Test Name", pickup.contactName
  end

  def test_invalid_address
    pickup1 = Pickup.new
    assert_raise(ArgumentError) { pickup1.validate! }

    pickup2 = Pickup.new({:invalid => "invalid"})
    assert_raise(ArgumentError) { pickup2.validate! }
  end
end
