require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class CancelReplyTest  < Test::Unit::TestCase

  def test_valid_cancel_reply
    cancel_reply = EShipper::CancelReply.new({:order_id => '123'})

    assert cancel_reply.validate!
    assert_equal '123', cancel_reply.order_id
  end

  def test_status_converts_status_id_to_cancel_readable_status
    status_ids = %w{1 2 3 4 5 7}
    status = ['READY FOR SHIPPING', 'IN TRANSIT'] +
      %w{DELIVERED CANCELLED EXCEPTION CLOSED}
    cancel_reply = EShipper::CancelReply.new
    
    status_ids.each_with_index do |id, i|
      cancel_reply.status = id
      assert_equal status[i], cancel_reply.status!
    end
  end
end