module EShipper
  class Response
    attr_reader :type, :xml, :time

    def initialize(type, xml, time = Time.now)
      @type = type
      @xml = xml
      @time = time
    end
  end
end