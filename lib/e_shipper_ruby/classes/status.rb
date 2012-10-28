module EShipper
  class Status < OpenStruct
    
    POSSIBLE_FIELDS = [ :name, :date, :assigned_by, :comments ]
    REQUIRED_FIELDS = []
    
    def initialize(attrs={})
      date = attrs.delete(:date) if attrs[:date]
      super
      self.date = Time.new(date) if date
    end
  end
end