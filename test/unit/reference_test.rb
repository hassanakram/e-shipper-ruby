require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class ReferenceTest  < Test::Unit::TestCase

  def test_valid_address
    reference = EShipper::Reference.new({:name => "Vitamonthly", :code => "123"})

    assert reference.validate!
    assert_equal "Vitamonthly", reference.name
    assert_equal "123", reference.code
  end

  def test_invalid_address
    reference1 = EShipper::Reference.new
    assert_raise(ArgumentError) { reference1.validate! }

    reference2 = EShipper::Reference.new({:invalid => "invalid"})
    assert_raise(ArgumentError) { reference2.validate! }
  end
end
