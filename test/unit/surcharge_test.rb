require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class SurchargeTest  < Test::Unit::TestCase

  def test_valid_surcharge
    surcharge = EShipper::Surcharge.new({:id => '1', :name => 'my surcharge', :amount => 3.45})

    assert surcharge.validate!
    assert_equal '1', surcharge.id
    assert_equal 'my surcharge', surcharge.name
    assert_equal 3.45, surcharge.amount
  end
end