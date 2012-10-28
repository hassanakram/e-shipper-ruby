require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class CodTest  < Test::Unit::TestCase
  
  def setup
    address = {:id => "234", :company => "Healthwave", :address1 => "185 Rideau Street", :address2=>"Second Floor",
      :city => "Ottawa", :state => "ON", :zip => "K1N 5X8", :country => "CA",
      :phone => '888-888-8888', :attention => 'fake attention', :email => 'eshipper@gmail.com'}
   
    options = {:payment_type => 'check', :address => address}
    
    @cod = EShipper::Cod.new(options)
  end
  
  def test_validate_validate_given_adddress 
    assert_nothing_raised { @cod.validate! }
    
    second_cod = EShipper::Cod.new({:payment_type => 'check'})
    assert_raises(ArgumentError) { second_cod.validate! }
    
    third_cod = EShipper::Cod.new({:payment_type => 'check',
      :address => { :company => 'healthwave', :address1 => ''}
    })
    assert_raises(ArgumentError) { third_cod.validate! }
  end
  
  def test_return_address_returns_a_hash_parsable_for_request_code
    result = @cod.return_address
    assert_equal "Healthwave", result[:codCompany]
    assert_equal "Ottawa", result[:codCity]
    assert_equal "185 Rideau Street", result[:codAddress1]
  end
end