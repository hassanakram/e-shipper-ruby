module EShipper
	class Request
		attr_reader :from, :to, :pickup, :packages, :references, :service_id

    COMMON_REQUEST_OPTIONS = {
      :QuoteRequest => {:insuranceType => "Carrier"},
      :ShippingRequest => {:insuranceType => "Carrier"},
      :Packages => {:type => "Package"},
      :Payment => {:type => "3rd Party"}
    }

    def initialize
      @packages, @references = [], []
    end

    def prepare!(data={}) 
      @from = EShipper::Address.new(data[:from]).validate! if data[:from]
      @to = EShipper::Address.new(data[:to]).validate! if data[:to]
      @pickup = EShipper::Pickup.new(data[:pickup]).validate! if data[:pickup]
      @service_id = data[:service_id] if data[:service_id]

      if packages = data[:packages] 
        packages.each do |package_data|
          @packages << EShipper::Package.new(package_data).validate!
        end
      end
 
      if references = data[:references]
        references.each do |reference_data|
          @references << EShipper::Reference.new(reference_data).validate!
        end
      end
    end

		def send_now
      uri = URI(EShipper::Client.instance.url)
      http_request = Net::HTTP::Post.new(uri.path)
      http_request.body = request_body
]
      http_response = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(http_request)
      end
      
      http_response.body 
   	end
	end
end