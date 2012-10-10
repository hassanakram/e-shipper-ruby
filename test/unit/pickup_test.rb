require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class PickupTest  < Test::Unit::TestCase

  def test_valid_package
    t = Time.now + 5 * 24 * 60 * 60 # 5 days from now

    pickup = EShipper::Pickup.new({:contactName => "Test Name", :phoneNumber => "888-888-8888", :location => "Front Door",
      :pickupDate => t.strftime("%Y-%m-%d"), :pickupTime => t.strftime("%H:%M"),
      :closingTime => (t+2*60*60).strftime("%H:%M")})

    assert pickup.validate!
    assert_equal "Front Door", pickup.location
    assert_equal "Test Name", pickup.contactName
  end

  def test_invalid_address
    pickup1 = EShipper::Pickup.new
    assert_raise(ArgumentError) { pickup1.validate! }

    pickup2 = EShipper::Pickup.new({:invalid => "invalid"})
    assert_raise(ArgumentError) { pickup2.validate! }
  end
  
  def test_description_render_html_of_the_pickup_content
    t = Time.now + 5 * 24 * 60 * 60 # 5 days from now
  
    pickup = EShipper::Pickup.new({:contactName => "Test Name", :phoneNumber => "888-888-8888", :pickupDate => t.strftime("%Y-%m-%d"),
        :pickupTime => t.strftime("%H:%M"), :closingTime => (t+2*60*60).strftime("%H:%M"), :location => "Front Door"})
  
    html = pickup.description
    assert html.include?('Test Name')
    assert html.include?('Front Door')
    assert html.include?(t.strftime("%H:%M"))
  end
end
