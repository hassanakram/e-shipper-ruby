require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class QuotesRequestsTest  < Test::Unit::TestCase

   def setup
    t = Time.now + 5 * 24 * 60 * 60 # 5 days from now
  
    pickup = EShipper::Pickup.new({:contactName => "Test Name", :phoneNumber => "888-888-8888", :pickupDate => t.strftime("%Y-%m-%d"),
        :pickupTime => t.strftime("%H:%M"), :closingTime => (t+2*60*60).strftime("%H:%M"), :location => "Front Door"})
  
    package1 = EShipper::Package.new({:length => "15", :width => "10", :height => "12", :weight => "10",
      :insuranceAmount => "120", :codAmount => "120"})
    package2 = EShipper::Package.new({:length => "15", :width => "10", :height => "10", :weight => "5",
      :insuranceAmount => "120", :codAmount => "120"})
   
    packages = [package1, package2]
    @options = EShipper::Client::COMMON_REQUEST_OPTIONS
    @client = EShipper::Client.new(:username => "vitamonthly", :password => "1234")
    @client.packages = packages
    @client.pickup = pickup
  end

  def test_parse_quotes_e_shipper_with_destination_in_canada
    @client.from = EShipper::Address.new({:id => "123", :company => "Vitamonthly", :address1 => "650 CIT Drive", 
      :city => "Livingston", :state => "ON", :zip => "L4J7Y9", :country => "CA"})
      
    @client.to = EShipper::Address.new({:id => '234', :company => "Home", :address1 => "1725 Riverside Drive", :address2=>"Apt B-2",
      :city => "Ottawa", :state => "ON", :zip => "K1G0E6", :country => "CA"})
    
    response = @client.parse_quotes @options
    assert_not_equal 0, response.count
    first_quote = response[0]
    assert first_quote, 'Problem with EShipper server'
    assert first_quote.is_a?(EShipper::Quote)
    assert_equal 'Purolator', first_quote.carrier_name
    assert_equal '4', first_quote.service_id
    assert_equal 'Purolator Express', first_quote.service_name
  end
  
  def test_parse_quotes_e_shipper_with_another_destination
    @client.from = EShipper::Address.new({:id => "123", :company => "Hospital", :address1 => "1403 29 Street NW", 
      :city => "Calgary", :state => "AB", :zip => "T2N2T9", :country => "CA"})
      
    @client.to = EShipper::Address.new({:id => '234', :company => "Hospital", :address1 => "909 Bd de la Verendrye",
      :city => "Gatineau", :state => "QC", :zip => "J8V2L6", :country => "CA"})
    
    response = @client.parse_quotes @options
    assert_not_equal 0, response.count
    first_quote = response[0]
    assert first_quote, 'Problem with EShipper server'
    assert_equal '6', first_quote.service_id
    assert_equal 'Purolator Ground 9AM', first_quote.service_name
  end
end