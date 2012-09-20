require 'test/unit'
require 'e_shipper_ruby'
require 'e_shipper_ruby/classes/pickup'

class EShipperRubyTest  < Test::Unit::TestCase

  def setup
    from = Address.new({:company=>"Vitamonthly", :address1=>"650 CIT Drive", :city=>"Livingston", :state=>"ON",
      :zip=>"L4J7Y9", :country=>"CA", :phone=>"888-888-8888", :attention => "Vitamonthly",
      :email => "eshipper@vitamonthly.com"})

    to = Address.new({:company=>"Home", :address1=>"1725 Riverside Drive", :city=>"Ottawa", :state=>"ON",
      :zip=>"K1G0E6", :country=>"CA", :phone=>"888-888-8888", :attention => "Vitamonthly",
      :email => "eshipper@vitamonthly.com"})

    t = Time.now + 5 * 24 * 60 * 60 # 5 days from now

    pickup = Pickup.new({:contactName=>"Test Name", :phoneNumber=>"888-888-8888", :pickupDate => t.strftime("%Y-%m-%d"),
        :pickupTime => t.strftime("%H:%M"), :closingTime => (t+2*60*60).strftime("%H:%M"), :location=>"Front Door"})

    package1 = Package.new({:length=>"15", :width=>"10", :height=>"12", :weight=>"10",
      :insuranceAmount=>"120"})
    package2 = Package.new({:length=>"15", :width=>"10", :height=>"10", :weight=>"5",
      :insuranceAmount=>"120"})

    packages = [package1, package2]

    @options = {:EShipper => {:username=>"vitamonthly", :password=>"1234", :version=>"3.0.0"},
      :QuoteRequest=>{:insuranceType=>"Carrier"},
      :From => from, :To => to,
      :Packages=>{:type=>"Package"}, :PackagesList => packages,
      :Pickup=>pickup}
  end

  def test_quote_request
    response = EShipper.quote_request(@options)
    puts response.body.to_s
    assert_match /QuoteReply/, response.body.to_s
    assert_match /Surcharge/, response.body.to_s
  end

  def test_shipping_request
    reference1 = Reference.new(:name => "Vitamonthly", :code => "123")
    reference2 = Reference.new(:name => "Heroku", :code => "456")
    references = [reference1, reference2]

    @options[:References] = references

    response = EShipper.shipping_request(@options)
    puts response.body.to_s
    assert_match /ShippingReply/, response.body.to_s
    assert_match /Order/, response.body.to_s
    assert_match /Carrier/, response.body.to_s
    assert_match /Surcharge/, response.body.to_s
  end
end
