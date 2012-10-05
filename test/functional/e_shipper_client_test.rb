require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class EShipperRubyTest  < Test::Unit::TestCase

  def setup
    @from = EShipper::Address.new({:id => "123", :company => "Vitamonthly", :address1 => "650 CIT Drive", :address2=>"Apt B-2",
      :city => "Livingston", :state => "ON", :zip => "L4J7Y9", :country => "CA", :phone => "888-888-8888",
      :attention => "Vitamonthly", :email => "eshipper@vitamonthly.com"})

    @to = EShipper::Address.new({:id => "456", :company => "Home", :address1 => "1725 Riverside Drive", :address2=>"Apt B-2",
      :city => "Ottawa", :state => "ON", :zip => "K1G0E6", :country => "CA", :phone => "888-888-8888",
      :attention => "Vitamonthly", :email => "eshipper@vitamonthly.com"})

    t = Time.now + 5 * 24 * 60 * 60 # 5 days from now

    @pickup = EShipper::Pickup.new({:contactName => "Test Name", :phoneNumber => "888-888-8888", :pickupDate => t.strftime("%Y-%m-%d"),
        :pickupTime => t.strftime("%H:%M"), :closingTime => (t+2*60*60).strftime("%H:%M"), :location => "Front Door"})

    package1 = EShipper::Package.new({:length => "15", :width => "10", :height => "12", :weight => "10",
      :insuranceAmount => "120", :codAmount => "120"})
    package2 = EShipper::Package.new({:length => "15", :width => "10", :height => "10", :weight => "5",
      :insuranceAmount => "120", :codAmount => "120"})

    @packages = [package1, package2]

    @options = {:EShipper => {:version => "3.0.0"},
      :QuoteRequest => {:insuranceType=>"Carrier"},
      :From => @from, :To => @to,
      :Packages => {:type=>"Package"}, :PackagesList => @packages,
      :Pickup => @pickup}

    @client = EShipper::Client.new(:username => "vitamonthly", :password => "1234")
  end

  def test_private_quote_request_with_options
    response = @client.send :send_request, @options
    p response
    p @client.responses[0].xml
    # assert response.xpath('//xmlns:QuoteReply'), "QuoteReply not included"
    # assert response.xpath('//xmlns:Quote'), "Quote not included"
    # assert response.xpath('//xmlns:Surcharge'), "Surchage not included"
  end
  
  # TODO: not working
  # def test_private_quote_request_by_filling_attributes
  #   options = {
  #     :EShipper => {:version => "3.0.0"},
  #     :QuoteRequest => {:insuranceType=>"Carrier"},
  #     :Packages => {:type=>"Package"}
  #   }
    
  #   @client.from = @from
  #   @client.to = @to
  #   @client.pickup = @pickup
  #   @client.packages = @packages
    
  #   response = @client.send :send_request, options
  # end

  # def test_private_shipping_request_with_options
  #   reference1 = EShipper::Reference.new(:name => "Vitamonthly", :code => "123")
  #   reference2 = EShipper::Reference.new(:name => "Heroku", :code => "456")
  #   references = [reference1, reference2]
  
  #   @options[:References] = references
  #   @options[:Payment] = {:type => "3rd Party"}
  
  #   response = @client.send :send_request, @options, 'shipping'
  
  #   assert response.xpath('//xmlns:ShippingReply'), "QuoteReply not included"
  #   assert response.xpath('//xmlns:Order'), "Quote not included"
  #   assert response.xpath('//xmlns:Package'), "Surchage not included"
  #   assert response.xpath('//xmlns:TrackingURL'), "QuoteReply not included"
  #   assert response.xpath('//xmlns:Quote'), "Quote not included"
  #   assert response.xpath('//xmlns:Surcharge'), "Surchage not included"
  # end
  
  # TODO: not working
  # def test_private_shipping_request_by_filling_attributes
  #   options = {
  #     :EShipper => {:version => "3.0.0"},
  #     :QuoteRequest => {:insuranceType=>"Carrier"},
  #     :Packages => {:type=>"Package"},
  #     :Payment => {:type => "3rd Party"}
  #   }
  #   reference1 = EShipper::Reference.new(:name => "Vitamonthly", :code => "123")
  #   reference2 = EShipper::Reference.new(:name => "Heroku", :code => "456")
    
  #   @client.from = @from
  #   @client.to = @to
  #   @client.pickup = @pickup
  #   @client.packages = @packages
  #   @client.references = [reference1, reference2]
  
  #   response = @client.send :send_request, options, 'shipping'
  
  #   assert response.xpath('//xmlns:ShippingReply'), "QuoteReply not included"
  #   assert response.xpath('//xmlns:Order'), "Quote not included"
  #   assert response.xpath('//xmlns:Package'), "Surchage not included"
  #   assert response.xpath('//xmlns:TrackingURL'), "QuoteReply not included"
  #   assert response.xpath('//xmlns:Quote'), "Quote not included"
  #   assert response.xpath('//xmlns:Surcharge'), "Surchage not included"
  # end
end
