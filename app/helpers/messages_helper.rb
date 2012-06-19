require 'yaml'
module MessagesHelper

  def to_groups_column(record)
    record.to_groups_array.map {|g| Group.find_by_id(g.to_i).to_s}.join(", ")
  end 

  def status_summary_column(record)
    status = record.current_status
    "deliv=#{status[:delivered]}, pend=#{status[:pending]}, reply=#{status[:replied]}, err=#{status[:errors]}"
  end
  
  def created_at_column(record)
    record.created_at.to_s(:date_time)
  end
  
  MessageStatuses = {
    -1 => 'Error',
     0 => 'Sent to gateway',
     1 => 'Pending (gateway)',
     2 => 'Delivered',
     3 => 'Response received'
     }
    
  MsgError = -1
  MsgSentToGateway = 0
  MsgPending = 1
  MsgDelivered = 2
  MsgResponseReceived = 3
  
  def msg_status_column(record)
    MessageStatuses[record.msg_status]
  end
   
end
