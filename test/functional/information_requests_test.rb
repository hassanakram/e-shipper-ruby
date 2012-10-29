require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class InformationRequestsTest  < Test::Unit::TestCase

  def test_e_shipper_order_information
    client = EShipper::Client.instance
    options = { :order_id => '2143130' }
    
    response = client.order_information options
    assert_not_nil response
    assert response.is_a?(EShipper::InformationReply)
    assert_equal '2143130', response.order_id
    assert response.shipment_date
    assert response.status
    assert !response.history.empty?
  end
end