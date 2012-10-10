require 'nokogiri'
require 'builder'

module EShipper
	class Request
		attr_accessor :from
		attr_accessor :to
		attr_accessor :pickup
		attr_accessor :packages

    COMMON_REQUEST_OPTIONS = {:EShipper => {:version => "3.0.0"},
      :QuoteRequest => {:insuranceType => "Carrier"},
      :Packages => {:type => "Package"}
    }

		def send_now options={}
			options.merge! COMMON_REQUEST_OPTIONS

      options[:From] = @from if @from
      options[:To] = @to if @to
      options[:Pickup] = @pickup if @pickup
      options[:PackagesList] = @packages if(@packages && !@packages.empty?)
      options[:References] = @references if(@references && !@references.empty?)
      options.symbolize_keys!

      request_body options

      uri = URI(@url)
      http_request = Net::HTTP::Post.new(uri.path)
      http_request.body = request_body

      http_response = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(http_request)
      end
 
      @responses << EShipper::Response.new(type, http_response.body)
      Nokogiri::XML(http_response.body)
    rescue NoMethodError
      raise "Verify that the mandatory data 'from', 'to', 'packages' are set on the client or in the request options"
		end
	end
end