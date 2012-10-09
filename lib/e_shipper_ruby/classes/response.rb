module EShipper
  class Response
    attr_reader :type, :xml, :time
    attr_accessor :errors

    def initialize(type, xml, time = Time.now)
      @type = type
      @xml = xml
      @time = time
      @errors = []
    end
  end
end