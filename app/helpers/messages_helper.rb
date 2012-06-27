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
    to_local_time(record.created_at)
  end

  def body_column(record)
    if record.sms_only && record.sms_only.size > 40
      record.sms_only
    else
      record.body[0..140]
    end
  end
  
  #  Generate or find the message id tag used to identify confirmation responses
  #  A bit complicated because of using different formats in the subject line and the
  #  message body, and a different format when presenting the message than when confirming it.
  #  Maybe that's totally unnecessary and we can come up with a single style.
  #  If action is :generate, the tag is created (a string)
  #  If action is :find, the tag is searched for; if found, the message number is returned
  #  If action is :confirm_tag, the confirmation form used in body is returned (e.g., '!500' w quotes)
  def message_id_tag(params={:id => 0, :text => nil, :location=>:body, :action=>:generate})
#puts "**** params=#{params}"
    case params[:action]
    when :generate
      if params[:location] == :body
        return "##{params[:id]}"
      else
        return "(SimJos message ##{params[:id]})"
      end
    when :find
      if params[:location] == :body
        params[:text] =~ /[\s\(\[]*!([0-9]*)/ || params[:text] =~ /confirm +[!#]([0-9]*)/i
        return $1 ? $1.to_i : nil
      else
        params[:text] =~ /SimJos message #([0-9]{1,9})\)/i
        return $1 ? $1.to_i : nil
      end
    when :confirm_tag    # This is for use in an explanation of how to confirm
      return "!#{params[:id]}"
    end
  end

  def find_message_id_tag(params={:subject=>nil, :body=>nil})
    message_id_tag(:action => :find, :text => params[:subject], :location => :subject) ||
    message_id_tag(:action => :find, :text => params[:body], :location => :body) 
  end  
  
  # Given response_time_limit in minutes, using current time 
  # generate phrase like 'immediately', by '2:43 pm', or
  # 'by 2:43 PM 24 Jun.' 
  def respond_by(response_time_limit, html=true)
    deadline = (Time.now + response_time_limit*60).in_time_zone(SIM::Application.config.time_zone)
    max_minutes = response_time_limit  # just renaming for convenience
    formatted = case max_minutes
    when 0..59 then "<strong>immediately</strong>"
    when 60..360 then "<strong>by #{deadline.strftime("%l:%M %p")}</strong>"
    else "by #{deadline.strftime("%l:%M %p %-d %b")}"
    end
    formatted.gsub!(/<strong>|<\/strong>/,'') unless html
    return formatted
  end
  
  MessageStatuses = {
    -1 => 'Error',
     0 => 'Sent',
     1 => 'Pending',
     2 => 'Delivered',
     3 => 'Responded'
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
