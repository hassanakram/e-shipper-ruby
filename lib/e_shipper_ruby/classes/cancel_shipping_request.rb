module EShipper
  class CancelShippingRequest < EShipper::Request
  attr_reader :order_id

  def initialize
  end

  def prepare!(data={})
      @order_id = data[:order_id] if data[:order_id]
  end

    def request_body
      client = EShipper::Client.instance

    builder = Nokogiri::XML::Builder.new do |xml|
        xml.EShipper(:version => "3.0.0", :xmlns => "http://www.eshipper.net/XMLSchema",
            :username => client.username, :password => client.password) do

          xml.ShipmentCancelRequest do
            xml.Order(:orderId => @order_id)
          end
        end
      end
      builder.to_xml
    end
  end
end

