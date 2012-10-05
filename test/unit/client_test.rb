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
  
  def test_parse_quotes_returns_an_array_of_quotes
    client = EShipper::Client.new :username => 'name', :password => '1234'
    xml_path = "#{File.dirname(__FILE__)}/../support/quote.xml"
    client.stubs(:send_request).returns Nokogiri::XML(File.open(xml_path))
    
    result = client.parse_quotes({})
  end
  
  def test_parse_shipping_returns_an_array_of_shippings
    client = EShipper::Client.new :username => 'name', :password => '1234'
    xml_path = "#{File.dirname(__FILE__)}/../support/shipping.xml"
    client.stubs(:send_request).returns Nokogiri::XML(File.open(xml_path))
    
    result = client.parse_shipping({})
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
