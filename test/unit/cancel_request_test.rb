require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class CancelShippingRequestTest  < Test::Unit::TestCase
  def setup
  	@cancel_request = EShipper::CancelShippingRequest.new

    options = { :order_id => '383363'}
    @cancel_request.prepare! options
  end

  def test_request_body_generating_a_well_formed_xml_quote_request
  	xml = @cancel_request.request_body
    doc = Nokogiri::XML(xml)

  	assert !doc.css('ShipmentCancelRequest').empty?
    assert !doc.css('Order').empty?
  end
end