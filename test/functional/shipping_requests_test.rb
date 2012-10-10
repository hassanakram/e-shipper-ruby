require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class ShippingRequestsTest  < Test::Unit::TestCase

  def setup
     from_data = {:id => "123", :company => "Hospital", :address1 => "1403 29 Street NW", 
      :city => "Calgary", :state => "AB", :zip => "T2N2T9", :country => "CA",
      :phone => '888-888-8888', :attention => 'vitamonthly', :email => 'damien@gmail.com'}
      
    to_data = {:id => '234', :company => "Hospital", :address1 => "909 Bd de la Verendrye",
      :city => "Gatineau", :state => "QC", :zip => "J8V2L6", :country => "CA",
      :phone => '888-888-8888', :attention => 'vitamonthly', :email => 'damien@gmail.com'}

    t = Time.now + 5 * 24 * 60 * 60 # 5 days from now
  
    pickup_data = {:contactName => "Test Name", :phoneNumber => "888-888-8888", :pickupDate => t.strftime("%Y-%m-%d"),
        :pickupTime => t.strftime("%H:%M"), :closingTime => (t+2*60*60).strftime("%H:%M"), :location => "Front Door"}
  
    package1_data = {:length => "15", :width => "10", :height => "12", :weight => "10",
      :insuranceAmount => "120", :codAmount => "120"}
    package2_data = {:length => "15", :width => "10", :height => "10", :weight => "5",
      :insuranceAmount => "120", :codAmount => "120"}
    packages = [package1_data, package2_data]
   
    reference1_data = {:name => "Vitamonthly", :code => "123"}
    reference2_data = {:name => "Heroku", :code => "456"}
    references = [reference1_data, reference2_data]
   
    @options = EShipper::Client::COMMON_REQUEST_OPTIONS
    @options[:Payment] = {:type => "3rd Party"}
    
    @client = EShipper::Client.instance
    @client.prepare_request!(from_data, to_data, pickup_data, packages, references)
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

  def test_sending_two_continuous_requests
    @options[:QuoteRequest].merge!({:serviceId => '4'})
    response = @client.parse_shipping @options
    assert !response[:errors]
    assert_equal 'Purolator Express', response.service_name

    response = @client.parse_shipping @options
    assert !response[:errors]
    assert_equal 'Purolator Express', response.service_name
  end
end
