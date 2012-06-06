require 'twiliolib'
require 'application_helper'
include ApplicationHelper
require 'httparty'
require 'uri'

class SmsController < ApplicationController
  include HTTParty
  skip_before_filter :verify_authenticity_token

  # Twilio sends the message to create just as if it were a web HTTP request
  # The create method should handle the incoming message by determining any actions
  # needed and sending a return message.
  def create  # need the name 'create' to conform with REST defaults, or change routes
#puts "IncomingController create: params=#{params}"
    from = params[:From]
    body = params[:Body]
    params.delete 'SmsSid'
    params.delete 'AccountSid'
    params.delete 'SmsMessageSid'
    if from_member(from)
      AppLog.create(:code => "SMS.received", :description=>"from #{from}: #{body}")
      resp = process_sms(body)[0..159]
      render :text => resp, :status => 200, :content_type => Mime::TEXT.to_s
      AppLog.create(:code => "SMS.reply", :description=>"to #{from}: #{resp}")
      if SiteSetting[:outgoing_sms].downcase == 'clickatell'
        from = '+2348162522097' if from =~/82591/
        send_clickatell(from, resp)
   #   send_clickatell('+2348162522097', "Response sent")
      end
    else  
      AppLog.create(:code => "SMS.rejected", :description=>"from #{from}: #{body}")
      render :text => "Refused", :status => 403, :content_type => Mime::TEXT.to_s
    end
  end 
  
  def clickatell_missing_parameters(user, pwd, api)
    if (user.blank? || pwd.blank? || api.blank?)
      error_msg = "Error - Clickatell settings not all defined or retrieved"
#puts "Error - Clickatell settings not all defined or retrieved" 
      AppLog.create(:severity=>'Error', :code=>'Clickatell.undefined', 
                    :description=> error_msg)
      return error_msg
    end
  end
  
   def send_clickatell(number, body)
    user = SiteSetting[:clickatell_user_name]
    pwd =  SiteSetting[:clickatell_password]
    api =  SiteSetting[:clickatell_api_id]
    missing = clickatell_missing_parameters(user, pwd, api)
    return missing if missing
    dest = number.gsub('+', '')  # Clickatell may not like '+' prefix
    clickatell_base_uri = "http://api.clickatell.com/http/sendmsg"
    uri = clickatell_base_uri + "?user=#{user}&password=#{pwd}&api_id=#{api}&to=#{dest}&text=#{URI.escape(body)}"
# puts "getting #{uri}" if Rails.env.to_s == 'test'
    reply =  HTTParty::get uri unless Rails.env.to_s == 'test'  # Careful with testing since this really sends messages!
    AppLog.create(:code => "SMS.sent.clickatell", 
      :description=>"to #{dest}: #{body[0..30]}, resp=#{reply}")
    return reply
  end

  # Send out a single message to an array of numbers.
  # Note that we could put logic here to change the gateway based on the number (US via one, Europe via another...)
  def send_multi(numbers, body, gateway=SmsGateway.new)
    gateway.send(numbers[0], body)
    #numbers.each {|number| self.send gateway_method, number, body}
  end

  def send_twilio(number, body='')  ### NOT FINISHED -- JUST TAKEN FROM AN ONLINE EXAMPLE!
      account = Twilio::RestAccount.new(ACCOUNT_SID, ACCOUNT_TOKEN)

      outgoing = {
          'From' => CALLER_ID,
          'To' => number,
          'Body' => "Test response"
      }

     resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/SMS/Messages",
                               'POST', outgoing)
     puts "#### code: %s\nbody: %s" % [resp.code, resp.body]
   end

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

