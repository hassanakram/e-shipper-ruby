require 'test/unit'
require 'e-shipper-ruby'

class EshipperTest  < Test::Unit::TestCase

  def setup
    @options = {:EShipper => {:xmlns=>"http://www.eshipper.net/XMLSchema",
        :username=>"vitamonthly", :password=>"1234", :version=>"3.0.0"},
      :QuoteRequest=>{:insuranceType=>"Carrier"},
      :From=>{:company=>"Vitamonthly", :address1=>"650 CIT Drive", :city=>"Livingston", :state=>"ON", :zip=>"L4J7Y9", :country=>"CA"},
      :To=>{:company=>"Home", :address1=>"1725 Riverside Drive", :city=>"Ottawa", :state=>"ON", :zip=>"K1G0E6", :country=>"CA"},
      :Packages=>{:type=>"Package"},
      :Pickup=>{:contactName=>"Test Name", :phoneNumber=>"888-888-8888", :pickupDate=>"2012-09-20", :pickupTime=>"16:30",
        :closingTime=>"17:45", :location=>"Front Door"}}

    @packages = [{:length=>"15", :width=>"10", :height=>"12", :weight=>"10",
      :insuranceAmount=>"120"},
      {:length=>"15", :width=>"10", :height=>"10", :weight=>"5",
      :insuranceAmount=>"120"}]
  end

  def test_quote_request
    response = EShipperRuby.quote_request(@options, @packages)
    puts response.body.to_s
    assert_match /QuoteReply/, response.body.to_s
    assert_match /Quote/, response.body.to_s
    assert_match /Surcharge/, response.body.to_s
  end

#  def test_shipping_request
#      assert true
#  end
end
