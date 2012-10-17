require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class ClientTest  < Test::Unit::TestCase

  def test_we_instanciate_a_singleton_instance
    assert_raise(NoMethodError) { EShipper::Client.new }
    assert_raise(NoMethodError) { EShipper::Client.new :username => '', :password => '1234' }
    assert_nothing_raised { EShipper::Client.instance }
  end

  def test_initialize_attrs_from_config_file
    client = EShipper::Client.instance
    assert_equal 'fake user', client.username
    assert_equal '1234', client.password
    assert_equal 'http://test.eshipper.com/eshipper/rpc2', client.url
  end
    
  def test_parse_quotes_returns_sorted_quotes_by_increasing_total_charge
    client = EShipper::Client.instance
    xml_path = "#{File.dirname(__FILE__)}/../support/quote.xml"
    doc = Nokogiri::XML(File.open(xml_path))
    Nokogiri.stubs(:XML).returns doc
    
    result = client.parse_quotes({})
    assert_equal 4, result.count
    assert result[0].is_a?(EShipper::Quote) 
    assert_equal '26.21', result[0].total_charge
    assert_equal '49.17', result[1].total_charge
    assert_equal '52.52', result[2].total_charge
    assert_equal '61.13', result[3].total_charge
  end
  
  def test_parse_quotes_returns_nested_e_shipper_objects
    client = EShipper::Client.instance
    xml_path = "#{File.dirname(__FILE__)}/../support/quote.xml"
    doc = Nokogiri::XML(File.open(xml_path))
    Nokogiri.stubs(:XML).returns doc
    
    result = client.parse_quotes({})
    first_result = result[0]
    assert_equal '2', first_result.carrier_id
    assert_equal '5', first_result.service_id 
    assert_equal 'Purolator Express 9AM', first_result.service_name
  
    surcharges = first_result.surcharges
    assert_equal 2, surcharges.count
    surcharge = surcharges[1]
    assert_equal 'null', surcharge.id
    assert_equal 'HST', surcharge.name
    assert_equal '7.04', surcharge.amount
  end
  
  def test_parse_quotes_returns_an_empty_array_and_trap_e_shipper_error_message
    client = EShipper::Client.instance
    xml_path = "#{File.dirname(__FILE__)}/../support/error.xml"
    doc = Nokogiri::XML(File.open(xml_path))
    Nokogiri.stubs(:XML).returns doc
    
    result = client.parse_quotes({})
    assert result.empty?
    assert !client.last_response.errors.empty?
  end
  
  def test_parse_shipping_returns_an_array_of_shippings
    client = EShipper::Client.instance
    xml_path = "#{File.dirname(__FILE__)}/../support/shipping.xml"
    doc = Nokogiri::XML(File.open(xml_path))
    Nokogiri.stubs(:XML).returns doc
    
    result = client.parse_shipping({})
    assert result.is_a?(EShipper::ShippingReply)
    assert_equal '2065293', result.order_id
    assert_equal 'Purolator', result.carrier_name
    assert_equal 'Purolator Express', result.service_name
    assert_equal %w{329014716131 329014716149}, result.package_tracking_numbers
    assert_equal 2, result.references.count
    reference = result.references[0]
    assert reference.is_a?(EShipper::Reference)
    assert_equal 'Vitamonthly', reference.name
    assert_equal '123', reference.code
    quote = result.quote
    assert quote.is_a?(EShipper::Quote)
    assert_equal '4', quote.service_id
    assert_equal 'Purolator Express', quote.service_name
    surcharge = quote.surcharges[0]
    assert surcharge.is_a?(EShipper::Surcharge)
    assert_equal '1899668', surcharge.id
    assert_equal 'Insurance', surcharge.name
    assert_equal '6.3', surcharge.amount
  end

  def test_parse_shipping_returns_nil_and_trap_e_shipper_error_message
    client = EShipper::Client.instance
    xml_path = "#{File.dirname(__FILE__)}/../support/error.xml"
    doc = Nokogiri::XML(File.open(xml_path))
    Nokogiri.stubs(:XML).returns doc
    
    result = client.parse_shipping({})
    assert !result
    assert !client.last_response.errors.empty?
  end
  
  def test_last_response_returns_last_response
    client = EShipper::Client.instance
    response = EShipper::Response.new('quote', '')
    client.responses << response
    
    assert_equal response, client.last_response
  end
  
  def test_validate_last_response_returns_false_if_last_response_contains_errors
    client = EShipper::Client.instance 
    response = EShipper::Response.new('quote', '')
    response.errors = ['Java Error: out of memory'] 
    client.responses << response
    
    assert !client.validate_last_response
  end
  
  def test_validate_last_response_returns_false_if_last_response_contains_empty_xml_result_data
    client = EShipper::Client.instance 
    response = EShipper::Response.new('quote', '')
    client.responses << response
    
    assert !client.validate_last_response
  end

  def test_validate_last_response_returns_true_if_last_response_contains_no_errors
    client = EShipper::Client.instance 
    response = EShipper::Response.new('quote', 'good xml response')
    client.responses << response
    
    assert client.validate_last_response
  end
end
