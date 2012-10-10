require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class AddressTest  < Test::Unit::TestCase

  def test_valid_address
    address = EShipper::Address.new({:id => "123", :company=>"Vitamonthly", :address1=>"650 CIT Drive", :address2=>"Apt B-2",
      :city=>"Livingston", :state=>"ON", :zip=>"L4J7Y9", :country=>"CA", :phone => "888-888-8888",
      :attention => "Vitamonthly", :email => "eshipper@vitamonthly.com"})

    assert address.validate!
    assert_equal "Vitamonthly", address.company
    assert_equal "eshipper@vitamonthly.com", address.email
  end

  def test_invalid_address
    address1 = EShipper::Address.new
    assert_raise(ArgumentError) { address1.validate! }

    address2 = EShipper::Address.new({:invalid => "invalid"})
    assert_raise(ArgumentError) { address2.validate! }
  end

  def test_nil_values_for_required_fields_are_not_allowed
     address = EShipper::Address.new({:id => "123", :company=>"Vitamonthly", :address1=>"650 CIT Drive", :address2=>"Apt B-2",
      :city=>"Livingston", :state=>"ON", :zip=>"L4J7Y9", :country => nil, :phone => nil,
      :attention => "Vitamonthly", :email => "eshipper@vitamonthly.com"})

     assert_raise(StandardError) { address.validate! } 
  end
  
  def test_description_render_html_of_the_address_content
    address = EShipper::Address.new({:id => "123", :company => "Vitamonthly", :address1 => "650 CIT Drive", 
      :city => "Livingston", :state => "ON", :zip => "L4J7Y9", :country => "CA"})

    html = address.description
    assert html.include?('123')
    assert html.include?('Livingston')
    assert html.include?('L4J7Y9')
  end
end
