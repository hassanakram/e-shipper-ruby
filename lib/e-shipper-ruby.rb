require "e-shipper-ruby/version"
require 'net/http'
require 'builder'

module EShipperRuby
  def request_quote(url = "http://www.e-shipper.net/rpc2", *options)
    request = post(url, build_request_quote_body(*options))
  end

  def build_request_quote_body(*options)
    builder = Builder::XmlMarkup.new
    builder.instruct!
    builder.EShipper("rxmlns" => "http://www.eshipper.net/XMLSchema",
      "username" => options[:username], "password" => options[:username], "version" => "3.0.0")
  end

  def post(url, request_body)
    uri = URI(url)
    http_request = Net::HTTP::Post.new(uri.path)

    http_request.body = request_body

    http_response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(http_request)
    end
  end
end
