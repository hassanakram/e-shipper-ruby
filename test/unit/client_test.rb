require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class ClientTest  < Test::Unit::TestCase
  def test_initialize_a_client_from_given_options
    username, password, url = %w{vitamonthly 1234 http://fake_url.com}
    client = EShipper::Client.new :username => username, :password => password, :url => url
    assert_equal username, client.username
    assert_equal password, client.password
    assert_equal url, client.url
  end
  
  def test_initialize_assigns_e_shipper_default_urls
    username, password = %w{vitamonthly 1234}
    client = EShipper::Client.new :username => username, :password => password
    assert_equal 'http://test.eshipper.com/eshipper/rpc2', client.url
   
    set_env_rails_equal_production

    client = EShipper::Client.new :username => username, :password => password
    assert_equal 'http://www.eshipper.com/rpc2', client.url
  end
  
  def test_initialize_give_priority_to_env_variables
    set_env_default_configuration
    username, password, url = %w{vitamonthly 1234 http://fake_url.com}
    client = EShipper::Client.new :username => username, :password => password, :url => url
    assert_equal ENV['E_SHIPPER_USERNAME'], client.username
    assert_equal ENV['E_SHIPPER_PASSWORD'], client.password
    assert_equal ENV['E_SHIPPER_URL'], client.url
  end
  
  def test_initialize_raises_error
    clear_env
    assert_raise(NoMethodError) { EShipper::Client.new }
    assert_raise(RuntimeError) { EShipper::Client.new :username => '', :password => '1234' }
    assert_raise(RuntimeError) { EShipper::Client.new :username => 'name', :password => '' }
  end
  
  def test_accessible_attributes
    assert_nothing_raised do
      client = EShipper::Client.new :username => 'name', :password => '1234'
      client.from
      client.to
      client.pickup
      client.packages
      client.references
    end
  end
  
  def test_parse_quotes_returns_sorted_quotes_by_increasing_total_charge
    client = EShipper::Client.new :username => 'name', :password => '1234'
    xml_path = "#{File.dirname(__FILE__)}/../support/quote.xml"
    client.stubs(:send_request).returns Nokogiri::XML(File.open(xml_path))
    
    result = client.parse_quotes({})
    assert_equal 3, result.count
    assert result[0].is_a?(EShipper::Quote) 
    assert_equal '26.21', result[0].total_charge
    assert_equal '49.17', result[1].total_charge
    assert_equal '61.13', result[2].total_charge
  end
  
  def test_parse_quotes_returns_neted_e_shipper_objects
    client = EShipper::Client.new :username => 'name', :password => '1234'
    xml_path = "#{File.dirname(__FILE__)}/../support/quote.xml"
    client.stubs(:send_request).returns Nokogiri::XML(File.open(xml_path))
    
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
  
  def test_parse_quotes_returns_the_message_error_when_trap_e_shipper_error_message
    client = EShipper::Client.new :username => 'name', :password => '1234'
    xml_path = "#{File.dirname(__FILE__)}/../support/error.xml"
    client.stubs(:send_request).returns Nokogiri::XML(File.open(xml_path))
    
    result = client.parse_quotes({})
    assert_equal({ :errors => ['Required field: Name is missing.'] }, result)
  end
  
  def test_parse_shipping_returns_an_array_of_shippings
    client = EShipper::Client.new :username => 'name', :password => '1234'
    xml_path = "#{File.dirname(__FILE__)}/../support/shipping.xml"
    client.stubs(:send_request).returns Nokogiri::XML(File.open(xml_path))
    
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

  def test_parse_shipping_returns_the_message_error_when_trap_e_shipper_error_message
    client = EShipper::Client.new :username => 'name', :password => '1234'
    xml_path = "#{File.dirname(__FILE__)}/../support/error.xml"
    client.stubs(:send_request).returns Nokogiri::XML(File.open(xml_path))
    
    result = client.parse_shipping({})
    assert_equal({ :errors => ['Required field: Name is missing.', 'The e_shipper response is empty'] }, result)
  end
  
  private
  
  def set_env_rails_equal_production 
    Kernel.const_set :Rails, nil
    def Rails.env
      'production'
    end
  end
  
  def set_env_default_configuration
    ENV['E_SHIPPER_USERNAME'] = 'fake username'
    ENV['E_SHIPPER_PASSWORD'] = 'fake password'
    ENV['E_SHIPPER_URL'] = 'fake url'
  end
  
  def clear_env
    ENV['E_SHIPPER_USERNAME'] = nil
    ENV['E_SHIPPER_PASSWORD'] = nil
    ENV['E_SHIPPER_URL'] = nil
  end
end
