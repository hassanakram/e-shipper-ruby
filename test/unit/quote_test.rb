require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class QuoteTest  < Test::Unit::TestCase

  def test_valid_quote
    quote = EShipper::Quote.new({:service_id => '123', :service_name => 'vitamonthly'})

    assert quote.validate!
    assert_equal '123', quote.service_id
    assert_equal 'vitamonthly', quote.service_name
  end

  def test_invalid_quote
    quote = EShipper::Quote.new
    assert_raise(ArgumentError) { quote.validate! }

    quote = EShipper::Quote.new({:invalid => "invalid"})
    assert_raise(ArgumentError) { quote.validate! }
  end
end