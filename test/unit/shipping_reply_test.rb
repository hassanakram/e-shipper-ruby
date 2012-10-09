require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class ShippingReplyTest  < Test::Unit::TestCase

  def test_valid_shipping_reply
    shipping_reply = EShipper::ShippingReply.new({:order_id => '123'})

    assert shipping_reply.validate!
    assert_equal '123', shipping_reply.order_id
  end

  def test_description_render_html_of_the_content_of_shipping_reply
    shipping_reply = EShipper::ShippingReply.new({:order_id => '123', :carrier_name => 'DHL', 
      :service_name => 'DHL express', :tracking_url => 'http://trac_me.com', :pickup_message => 'available at your door'
    })
    quote = EShipper::Quote.new({:service_id => '123', :service_name => 'vitamonthly', :service_id => '4',
      :service_name => 'puralator express', :transport_mode => 'plane', :transit_days => '2', 
      :currency => 'CAD', :base_charge => '4.12', :fuel_surcharge => '2.0', :total_charge => '6.12'
    })
    first_ref = EShipper::Reference.new({:name => "Vitamonthly", :code => "AAA"})
    second_ref = EShipper::Reference.new({:name => "second", :code => "BBB"})
    shipping_reply.references = [first_ref, second_ref]
    shipping_reply.package_tracking_numbers = ['456', '789']
    shipping_reply.quote = quote

    html = shipping_reply.description
    assert html.include?('123')
    assert html.include?('DHL')
    assert html.include?('DHL express')
    #NOTE: test presence of tracking numbers
    assert html.include?('456')
    assert html.include?('789')
    #NOTE: test presence of references
    assert html.include?("Vitamonthly")
    assert html.include?("AAA")
    assert html.include?("BBB")
    #NOTE: test presence of quotes
    assert html.include?('puralator express')
    assert html.include?('2.0')
  end
end