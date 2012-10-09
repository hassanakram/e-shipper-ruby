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

  def test_description_render_html_of_the_content_of_a_quote
    quote = EShipper::Quote.new({:service_id => '123', :service_name => 'vitamonthly', :service_id => '4',
      :service_name => 'puralator express', :transport_mode => 'plane', :transit_days => '2', 
      :currency => 'CAD', :base_charge => '4.12', :fuel_surcharge => '2.0', :total_charge => '6.12'
    })

    html = quote.description
    assert html.include?('plane')
    assert html.include?('2')
    assert html.include?('CAD')
    assert html.include?('4.12')
    assert html.include?('2.0')
    assert html.include?('6.12')
    assert !html.include?('vitamonthly')

    quote_with_empty_attr = EShipper::Quote.new({:service_id => '123', :service_name => 'vitamonthly', :service_id => '4',
      :service_name => 'puralator express', :transport_mode => ''})

    html = quote_with_empty_attr.description
    assert !html.include?('transport_mode')
  end
end