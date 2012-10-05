require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class ShippingReplyTest  < Test::Unit::TestCase

  def test_valid_shipping_reply
    shipping_reply = EShipper::ShippingReply.new({:order_id => '123'})

    assert shipping_reply.validate!
    assert_equal '123', shipping_reply.order_id
  end
end