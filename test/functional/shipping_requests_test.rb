require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class ShippingRequestsTest  < Test::Unit::TestCase

  def setup
    @options = {}

    @options[:from] = {:id => "123", :company => "fake company", :address1 => "650 CIT Drive", 
      :city => "Livingston", :state => "ON", :zip => "L4J7Y9", :country => "CA",
      :phone => '888-888-8888', :attention => 'fake attention', :email => 'eshipper@gmail.com'}

    @options[:to] = {:id => "234", :company => "Healthwave", :address1 => "185 Rideau Street", :address2=>"Second Floor",
      :city => "Ottawa", :state => "ON", :zip => "K1N 5X8", :country => "CA",
      :phone => '888-888-8888', :attention => 'fake attention', :email => 'eshipper@gmail.com'}

    t = Time.now + 5 * 24 * 60 * 60 # 5 days from now
  
    @options[:pickup] = {:contactName => "Test Name", :phoneNumber => "888-888-8888", :pickupDate => t.strftime("%Y-%m-%d"),
        :pickupTime => t.strftime("%H:%M"), :closingTime => (t+2*60*60).strftime("%H:%M"), :location => "Front Door"}
  
    package1_data = {:length => "15", :width => "10", :height => "12", :weight => "10",
      :insuranceAmount => "120", :codAmount => "120"}
    package2_data = {:length => "15", :width => "10", :height => "10", :weight => "5",
      :insuranceAmount => "120", :codAmount => "120"}
    @options[:packages] = [package1_data, package2_data]
   
    reference1_data = {:name => "Vitamonthly", :code => "123"}
    reference2_data = {:name => "Heroku", :code => "456"}
    @options[:references] = [reference1_data, reference2_data]
   
    @client = EShipper::Client.instance
  end

  def test_parse_shipping_e_shipper_without_service_id
    response = @client.parse_shipping @options
    assert @client.validate_last_response
    assert response.is_a?(EShipper::ShippingReply)
    assert !response.tracking_url.empty?
    assert !response.service_name.empty?
    assert !response.package_tracking_numbers.empty?
  end
  
  def test_parse_shipping_e_shipper_with_service_id
    @options[:service_id] = '4'
    response = @client.parse_shipping @options
    assert @client.validate_last_response
    assert_equal 'Purolator Express', response.service_name
    assert !response.tracking_url.empty?
    assert !response.service_name.empty?
    assert !response.package_tracking_numbers.empty?
  end

  def test_sending_two_continuous_requests
    response = @client.parse_shipping @options
    assert @client.validate_last_response
   
    response = @client.parse_shipping @options
    assert @client.validate_last_response
  end

  def test_sending_a_quote_request_following_by_a_shipping_one_dont_break_the_server
    @options[:from] = {:id => "123", :company => "Hospital", :address1 => "1403 29 Street NW", 
      :city => "Calgary", :state => "AB", :zip => "T2N2T9", :country => "CA",
      :phone => '888-888-8888', :attention => 'vitamonthly', :email => 'damien@gmail.com'}
      
    @options[:to] == {:id => '234', :company => "Hospital", :address1 => "909 Bd de la Verendrye",
      :city => "Gatineau", :state => "QC", :zip => "J8V2L6", :country => "CA",
    :phone => '888-888-8888', :attention => 'vitamonthly', :email => 'damien@gmail.com'}

    response = @client.parse_quotes @options
    assert !response.nil?
    
    response = @client.parse_shipping @options
    assert !response.nil?
  end

  def test_obtaining_invoice_data
    @options[:invoice] = { :broker_name => 'John Doe', :contact_company => 'MERITCON INC',
      :name => 'Jim', :contact_name => 'Rizwan', :contact_phone => '555-555-4444',
      :dutiable => 'true', :duty_tax_to => 'receiver'
    }

    @options[:items] = [{:code => '1234', :description => 'Laptop computer', :originCountry =>  'US', 
        :quantity => '100', :unitPrice => '1000.00'}]

    response = @client.parse_shipping @options
    assert !response.customer_invoice.nil?
  end
end
