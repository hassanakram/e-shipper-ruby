require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class QuotesRequestsTest  < Test::Unit::TestCase

   def setup
    @options = {}

    t = Time.now + 5 * 24 * 60 * 60 # 5 days from now
  
    @options[:pickup] = {:contactName => "Test Name", :phoneNumber => "888-888-8888", :pickupDate => t.strftime("%Y-%m-%d"),
        :pickupTime => t.strftime("%H:%M"), :closingTime => (t+2*60*60).strftime("%H:%M"), :location => "Front Door"}
  
    package1_data = {:length => "15", :width => "10", :height => "12", :weight => "10",
      :insuranceAmount => "120", :codAmount => "120"}
    package2_data = {:length => "15", :width => "10", :height => "10", :weight => "5",
      :insuranceAmount => "120", :codAmount => "120"}
    
    @options[:packages] = [package1_data, package2_data]

    @client = EShipper::Client.instance
  end

  def test_parse_quotes_e_shipper_with_destination_in_canada
    @options[:from] = {:id => "123", :company => "Vitamonthly", :address1 => "650 CIT Drive", 
      :city => "Livingston", :state => "ON", :zip => "L4J7Y9", :country => "CA",
      :phone => '888-888-8888', :attention => 'vitamonthly', :email => 'damien@gmail.com'}
      
    @options[:to] = {:id => '234', :company => "Home", :address1 => "1725 Riverside Drive", :address2=>"Apt B-2",
      :city => "Ottawa", :state => "ON", :zip => "K1G0E6", :country => "CA",
      :phone => '888-888-8888', :attention => 'vitamonthly', :email => 'damien@gmail.com'}
    
    response = @client.parse_quotes @options
    assert_not_equal 0, response.count
    first_quote = response[0]
    assert first_quote, 'Problem with EShipper server'
    assert first_quote.is_a?(EShipper::Quote)
    assert first_quote.carrier_name
    assert first_quote.service_id
    assert first_quote.service_name
  end
  
  def test_parse_quotes_e_shipper_with_another_destination
    @options[:from] = {:id => "123", :company => "Hospital", :address1 => "1403 29 Street NW", 
      :city => "Calgary", :state => "AB", :zip => "T2N2T9", :country => "CA",
      :phone => '888-888-8888', :attention => 'vitamonthly', :email => 'damien@gmail.com'}
      
    @options[:to] = {:id => '234', :company => "Hospital", :address1 => "909 Bd de la Verendrye",
      :city => "Gatineau", :state => "QC", :zip => "J8V2L6", :country => "CA",
      :phone => '888-888-8888', :attention => 'vitamonthly', :email => 'damien@gmail.com'}
    
    response = @client.parse_quotes @options
    assert_not_equal 0, response.count
    first_quote = response[0]
    assert first_quote, 'Problem with EShipper server'
    assert_equal '6', first_quote.service_id
    assert_equal 'Purolator Express 1030', first_quote.service_name
  end

  def test_sending_2_continous_requests_dont_break_the_server
    @options[:from]= {:id => "123", :company => "Vitamonthly", :address1 => "650 CIT Drive", 
      :city => "Livingston", :state => "ON", :zip => "L4J7Y9", :country => "CA",
      :phone => '888-888-8888', :attention => 'vitamonthly', :email => 'damien@gmail.com'}
      
    @options[:to] = {:id => '234', :company => "Home", :address1 => "1725 Riverside Drive", :address2=>"Apt B-2",
      :city => "Ottawa", :state => "ON", :zip => "K1G0E6", :country => "CA",
      :phone => '888-888-8888', :attention => 'vitamonthly', :email => 'damien@gmail.com'}

    response = @client.parse_quotes @options
    assert_not_equal 0, response.count

    response = @client.parse_quotes @options
    assert_not_equal 0, response.count
  end

end