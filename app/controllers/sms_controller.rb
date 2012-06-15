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
#puts "IncomingController create: params=#{params}"
    from = params[:From]  # The phone number of the sender
    body = params[:Body]  # This is the body of the incoming message
    params.delete 'SmsSid'
    params.delete 'AccountSid'
    params.delete 'SmsMessageSid'
    if from_member(from)  # We only accept SMS from registered phone numbers of members
      AppLog.create(:code => "SMS.received", :description=>"from #{from}: #{body}")
      resp = process_sms(body)[0..159]    # generate response
      render :text => resp, :status => 200, :content_type => Mime::TEXT.to_s  # Confirm w incoming gateway that msg received
      AppLog.create(:code => "SMS.reply", :description=>"to #{from}: #{resp}")
      if SiteSetting[:outgoing_sms].downcase == 'clickatell'  # It's our only gateway so far
        from = '+2348162522097' if from =~/82591/  # This is only for testing! Remove 
        ClickatellGateway.new.deliver(from, resp)
   #$   send_clickatell('+2348162522097', "Response sent")
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
           when 'info' then do_info(text)  
           # More commands go here ...
           else
             "unknown '#{command}'. Info=" + (do_info(text) if Member.find_with_name(text))
           end
  end
  
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

  def from_member(from) 
    return true if from == '+16199282591' # Mike's Google Voice number for testing
    Contact.find_by_phone_1(from) || Contact.find_by_phone_2(from)
  end

end # Class

