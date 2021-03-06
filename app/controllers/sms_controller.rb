require 'twiliolib'
require 'application_helper'
include ApplicationHelper
require 'httparty'
require 'uri'
require 'sms_gateway'

class SmsController < ApplicationController
  include HTTParty
  skip_before_filter :verify_authenticity_token

  # Create - handle incoming SMS message from Twilio
  #
  # Twilio sends the message to create just as if it were a web HTTP request
  # The create method should handle the incoming message by determining any actions
  # needed and sending a return message.
  # ToDo
  # Remove line for testing; configure for other gateways
  def create  # need the name 'create' to conform with REST defaults, or change routes
 #puts "**** IncomingController create: params=#{params}"
    from = params[:From]  # The phone number of the sender
    body = params[:Body]  # This is the body of the incoming message
    AppLog.create(:code => "SMS.incoming", :description=>"from=#{from}; body=#{body[0..50]}")
    params.delete 'SmsSid'
    params.delete 'AccountSid'
    params.delete 'SmsMessageSid'
    @possible_senders = from_members(from)  # all members from this database with matching phone number
    @sender = @possible_senders.first # choose one of them
#puts "**** @possible_senders=#{@possible_senders}, @sender=#{@sender}"
    if @sender  # We only accept SMS from registered phone numbers of members
      begin
        AppLog.create(:code => "SMS.received", :description=>"from #{from} (#{@sender.shorter_name}): #{body}")
        resp = process_sms(body)[0..159]    # generate response
        render :text => resp, :status => 200, :content_type => Mime::TEXT.to_s  # Confirm w incoming gateway that msg received
        AppLog.create(:code => "SMS.reply", :description=>"to #{from}: #{resp}")
        ClickatellGateway.new.deliver(from, resp)
#      rescue
#        AppLog.create(:code => "SMS.system_error", :description=>"on create: #{$!}")
#        render :text => "Internal", :status => 500, :content_type => Mime::TEXT.to_s
#        ClickatellGateway.new.deliver(from, "Sorry, there is a bug in my system and I crashed :-(" )
      end
    else  
      AppLog.create(:code => "SMS.rejected", :description=>"from #{from}: #{body}")
      render :text => "Refused", :status => 403, :content_type => Mime::TEXT.to_s
    end
  end 
  

#  def send_twilio(number, body='')  ### NOT FINISHED -- JUST TAKEN FROM AN ONLINE EXAMPLE!
#      account = Twilio::RestAccount.new(ACCOUNT_SID, ACCOUNT_TOKEN)

#      outgoing = {
#          'From' => CALLER_ID,
#          'To' => number,
#          'Body' => "Test response"
#      }

#     resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/SMS/Messages",
#                               'POST', outgoing)
#     puts "#### code: %s\nbody: %s" % [resp.code, resp.body]
#   end

private

  # Parse the message received from mobile
  def process_sms(body)
    return "Nothing found in your message!" if body.blank?
    command, text = extract_commands(body)[0] # parse to first word=command, rest = text
    return case command.downcase
           when 'd' then group_deliver(text)
           when 'group', 'groups' then do_list_groups
           when 'info' then do_info(text)  
           when 'location' then do_location(text)  
           when '?', 'help' then do_help(text)
           when /\A!/ then process_response(command, text)
           # More commands go here ...
           else
             "unknown '#{command}'. Info=" + (do_info(text) if Member.find_with_name(text))
           end
  end

  # Return help
  # ToDo -- add specific help about commands
  def do_help(text)
    command_summary = [ ['d <group>', 'deliver msg to grp'], 
                        ['groups', 'list main grps'],
                        ['info <name>', 'get contact info'],
                        ['location <place>', 'set current loc'],
                        ['!21 <reply>', 'reply to msg 21']
                      ]
    command_summary.map {|c| "#{c[0]} = #{c[1]}"}.join("\n")
  end
  
  # Send a list of abbreviations for the "primary" groups (primary meaning that)
  # they're important enough to fit into this 160-character string
  def do_list_groups()
    "Some groups: " + Group.primary_group_abbrevs
  end                    
  
  def do_location(text)
#puts "****do_location text=#{text}, @sender=#@sender"
    if text
      if text =~ /( for|next|for next)?\s([\d]+)/
        duration = $2.to_i  # the number of hours
        location = $`.strip  # part preceding the match, i.e. the location itself
#puts "****location=#{location}, duration=#{duration}"
      else
        duration = DefaultReportedLocDuration
        location = text.strip
      end
      location.sub!(/\A(in |at )/, '')
#puts "**** location after sub=#{location}"
      @sender.update_reported_location(location, Time.now, Time.now + duration*3600) # last is expiration time, now + duration hours
      return "Your location has been updated to #{location} for the next #{duration} hours."
    else
      return "I don't understand. Say something like \"location JETS next 6 hours\" or " +
             "\"location office\" or even just \"location HQ 6\". "
    end
  end  

  # Return info about an individual named in text  
  def do_info(text)
    member = Member.find_with_name(text).first  
    if member
      return (member.last_name_first(:initial=>true) + ' ' + contact_info(member) + '. ' +
        member.current_location)
    else
      return "#{text} not found in database"
    end
  end    
  
  def contact_info(member)
    contact = member.primary_contact
    if contact
      email = contact.summary['Email'].split(',')[0] # use only the first email address
      return "#{contact.summary['Phone']} #{email}" 
    else
      return "**no contact info found**"
    end
  end

  def group_deliver(text)
#puts "**** group_deliver"    
    target_group, body = text.sub(' ',"\x0").split("\x0") # just a way of stripping the first word as the group name
    group = Group.find(:first, 
      :conditions => [ "lower(group_name) = ? OR lower(abbrev) = ?", target_group.downcase, target_group.downcase])
    if group   # if we found the group requested by the sender
      sender_name = @sender.shorter_name
      body = body[0..148-sender_name.size] + '-' + sender_name  # Truncate msg and add sender's name
      message = Message.new(:send_sms=>true, :to_groups=>group.id, :sms_only=>body)
      message.deliver  # Don't forget to deliver!
      return("sent to #{group.group_name}")
    else
      return( ("Error: no group #{target_group}. Send command 'groups' to list the main ones incl " +
               Group.primary_group_abbrevs)[0..160] )
    end
  end

  # The user has sent an SMS text confirming response of a previous message
  def process_response(command, text)
    message_id = command[1..99]
    message = Message.find_by_id(message_id)
#puts "**** command=#{command}, text=#{text}, @sender.id=#{@sender.id}, message=#{message.id}"
    if message
      @possible_senders.each do |a_member|
        message.process_response(:member => a_member, :response => text, :mode => 'SMS')
      end
      return("Thanks for your response :-)")
    else
      return("Thanks for responding, but message number #{message_id} was not found. Check the number again.")
    end
##    target = SentMessage.where("member_id = ? AND message_id = ?", @sender.id, command[1..99].to_i)[0]
#    target = SentMessage.where("member_id = ?", @sender.id)[0]
#puts "**** target=#{target}"
#target.should_not == nil
    return ''
  end

  def from_members(from) 
    Member.find_by_phone(from)
  end

end # Class

