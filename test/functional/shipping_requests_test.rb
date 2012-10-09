require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class ShippingRequestsTest  < Test::Unit::TestCase

  def setup
    t = Time.now + 5 * 24 * 60 * 60 # 5 days from now
  
    pickup = EShipper::Pickup.new({:contactName => "Test Name", :phoneNumber => "888-888-8888", :pickupDate => t.strftime("%Y-%m-%d"),
        :pickupTime => t.strftime("%H:%M"), :closingTime => (t+2*60*60).strftime("%H:%M"), :location => "Front Door"})
  
    package1 = EShipper::Package.new({:length => "15", :width => "10", :height => "12", :weight => "10",
      :insuranceAmount => "120", :codAmount => "120"})
    package2 = EShipper::Package.new({:length => "15", :width => "10", :height => "10", :weight => "5",
      :insuranceAmount => "120", :codAmount => "120"})
   
    reference1 = EShipper::Reference.new(:name => "Vitamonthly", :code => "123")
    reference2 = EShipper::Reference.new(:name => "Heroku", :code => "456")
    references = [reference1, reference2]
   
    packages = [package1, package2]
    @options = EShipper::Client::COMMON_REQUEST_OPTIONS
    @options[:Payment] = {:type => "3rd Party"}
    @client = EShipper::Client.new(:username => "vitamonthly", :password => "1234")
    @client.packages = packages
    @client.pickup = pickup
    @client.references = references
    @client.from = EShipper::Address.new({:id => "123", :company => "Hospital", :address1 => "1403 29 Street NW", 
      :city => "Calgary", :state => "AB", :zip => "T2N2T9", :country => "CA",
      :phone => '888-888-8888', :attention => 'vitamonthly', :email => 'damien@gmail.com'})
      
    @client.to = EShipper::Address.new({:id => '234', :company => "Hospital", :address1 => "909 Bd de la Verendrye",
      :city => "Gatineau", :state => "QC", :zip => "J8V2L6", :country => "CA",
      :phone => '888-888-8888', :attention => 'vitamonthly', :email => 'damien@gmail.com'})
  end

  def test_parse_shipping_e_shipper_without_service_id
    response = @client.parse_shipping @options
    assert !response[:errors]
    assert response.is_a?(EShipper::ShippingReply)
    assert !response.tracking_url.empty?
    assert !response.service_name.empty?
    assert !response.package_tracking_numbers.empty?
  end
  
  def test_parse_shipping_e_shipper_with_service_id
    @options[:QuoteRequest].merge!({:serviceId => '4'})
    response = @client.parse_shipping @options
    assert !response[:errors]
    assert_equal 'Purolator Express', response.service_name
    assert !response.tracking_url.empty?
    assert !response.service_name.empty?
    assert !response.package_tracking_numbers.empty?
  end
end
