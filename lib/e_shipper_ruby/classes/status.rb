module EShipper
  class Status < OpenStruct
    
    POSSIBLE_FIELDS = [ :name, :date, :assigned_by, :comments ]
    REQUIRED_FIELDS = []
  end
end