require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class CancelRequestsTest  < Test::Unit::TestCase

  def test_e_shipper_cancel_shipping
    client = EShipper::Client.instance
    options = { :order_id => '2143130' }
    
    response = client.cancel_shipping options
    assert_not_nil response
    assert response.is_a?(EShipper::CancelReply)
    assert_equal '2143130', response.order_id
    assert_equal 'Order has been cancelled!', response.message
    assert_equal 'CANCELLED', response.status
  end
end