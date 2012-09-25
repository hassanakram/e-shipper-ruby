require 'test/unit'
require 'e_shipper_ruby'

class EShipperRubyTest  < Test::Unit::TestCase

  def setup
    from = EShipper::Address.new({:id => "123", :company => "Vitamonthly", :address1 => "650 CIT Drive", :address2=>"Apt B-2",
      :city => "Livingston", :state => "ON", :zip => "L4J7Y9", :country => "CA", :phone => "888-888-8888",
      :attention => "Vitamonthly", :email => "eshipper@vitamonthly.com"})

    to = EShipper::Address.new({:id => "456", :company => "Home", :address1 => "1725 Riverside Drive", :address2=>"Apt B-2",
      :city => "Ottawa", :state => "ON", :zip => "K1G0E6", :country => "CA", :phone => "888-888-8888",
      :attention => "Vitamonthly", :email => "eshipper@vitamonthly.com"})

    t = Time.now + 5 * 24 * 60 * 60 # 5 days from now

    pickup = EShipper::Pickup.new({:contactName => "Test Name", :phoneNumber => "888-888-8888", :pickupDate => t.strftime("%Y-%m-%d"),
        :pickupTime => t.strftime("%H:%M"), :closingTime => (t+2*60*60).strftime("%H:%M"), :location => "Front Door"})

    package1 = EShipper::Package.new({:length => "15", :width => "10", :height => "12", :weight => "10",
      :insuranceAmount => "120", :codAmount => "120"})
    package2 = EShipper::Package.new({:length => "15", :width => "10", :height => "10", :weight => "5",
      :insuranceAmount => "120", :codAmount => "120"})

    packages = [package1, package2]

    @options = {:EShipper => {:username=>"vitamonthly", :password => "1234", :version => "3.0.0"},
      :QuoteRequest => {:insuranceType=>"Carrier"},
      :From => from, :To => to,
      :Packages => {:type=>"Package"}, :PackagesList => packages,
      :Pickup => pickup}
  end

  def assert_include(container, include_child)
    container.each do |element|
      assert element.include?(include_child), "#{include_child} not included"
    end
  end

  def test_quote_request
    response = EShipper.quote_request(@options)

    assert response.include?("QuoteReply"), "QuoteReply not included"
    assert_include response["QuoteReply"], "Quote"
    assert_include response["QuoteReply"][0]["Quote"], "Surcharge"
  end

  def test_shipping_request
    reference1 = EShipper::Reference.new(:name => "Vitamonthly", :code => "123")
    reference2 = EShipper::Reference.new(:name => "Heroku", :code => "456")
    references = [reference1, reference2]

    @options[:References] = references
    @options[:Payment] = {:type => "3rd Party"}

    response = EShipper.shipping_request(@options)

    assert response.include?("ShippingReply"), "ShippingReply not included"
    assert_include response["ShippingReply"], "Order"
    assert_include response["ShippingReply"], "Package"
    assert_include response["ShippingReply"], "TrackingURL"
    assert_include response["ShippingReply"], "Quote"
    assert_include response["ShippingReply"][0]["Quote"], "Surcharge"
  end
end
