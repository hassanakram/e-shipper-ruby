module EShipper
  class CancelReply < OpenStruct
  
    POSSIBLE_FIELDS = [:order_id, :message, :status]
    REQUIRED_FIELDS = []
    
    def status!
      self.status =
      case self.status
      when '1' then 'READY FOR SHIPPING'
      when '2' then 'IN TRANSIT'
      when '3' then 'DELIVERED'
      when '4' then 'CANCELLED'
      when '5' then 'EXCEPTION'
      when '7' then 'CLOSED'
      end
    end
  end
end