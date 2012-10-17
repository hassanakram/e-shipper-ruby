require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class OpenStructTest  < Test::Unit::TestCase
  
  def test_validation_of_any_descendants
    address = EShipper::Address.new({:id => "123", :company => "fake company", :address1 => "650 CIT Drive", 
      :address2 => "Apt B-2", :city => "Livingston", :state => "ON", :zip => "L4J7Y9", :country => "CA", 
      :phone => "888-888-8888", :attention => "fake attention", :email => "eshipper@gmail.com"})

    assert address.validate!
    assert_equal "fake company", address.company
    assert_equal "eshipper@gmail.com", address.email
  end

  def test_errors_validation_of_any_descendants
    address1 = EShipper::Address.new
    assert_raise(ArgumentError) { address1.validate! }

    address2 = EShipper::Address.new({:invalid => "invalid"})
    assert_raise(ArgumentError) { address2.validate! }
  end

  def test_nil_values_for_required_fields_are_not_allowed
     address = EShipper::Address.new({:id => "123", :company => "fake company", :address1 => "650 CIT Drive", 
      :address2 => "Apt B-2", :city => "Livingston", :state => "ON", :zip => "L4J7Y9", :country => nil, :phone => nil,
      :attention => "fake attention", :email => "eshipper@gmail.com"})

     assert_raise(ArgumentError) { address.validate! } 
  end
  
  def test_description_render_html_of_any_descendants
    address = EShipper::Address.new({:id => "123", :company => "fake company", :address1 => "650 CIT Drive", 
      :city => "Livingston", :state => "ON", :zip => "L4J7Y9", :country => "CA"})

    html = address.description
    assert html.include?('123')
    assert html.include?('Livingston')
    assert html.include?('L4J7Y9')
  end
end