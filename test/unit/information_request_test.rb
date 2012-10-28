require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class OrderInformationRequestTest  < Test::Unit::TestCase
  def setup
  	@info_request = EShipper::OrderInformationRequest.new

    options = { :order_id => '383363'}
    @info_request.prepare! options
  end

  def test_request_body_generating_a_well_formed_xml_information_request
  	xml = @info_request.request_body
    doc = Nokogiri::XML(xml)

  	assert !doc.css('OrderInformationRequest').empty?
    assert !doc.css('Order').empty?
  end
end