require 'twiliolib'
require 'application_helper'
include ApplicationHelper
require 'httparty'
require 'uri'

class SmsController < ApplicationController
  include HTTParty
  skip_before_filter :verify_authenticity_token

  def create  # need the name 'create' to conform with REST defaults, or change routes
#puts "IncomingController create: params=#{params}"
    from = params[:From]
    body = params[:Body]
    params.delete 'SmsSid'
    params.delete 'AccountSid'
    params.delete 'SmsMessageSid'
    CalendarEvent.create(:date=>Time.now, 
        :event => "Received SMS from #{from}: #{body}; #{params}"[0,240])
    if from_member(from)
      resp = process_sms(body)[0..159]
#member = Member.find_by_last_name(body.strip)
#resp = member ? "#{member.full_name_short} is at #{member.current_location}" : "Unknown '#{body.strip}'"
      render :text => resp, :status => 200, :content_type => Mime::TEXT.to_s
      if SiteSetting[:outgoing_sms].downcase == 'clickatell'
      send_clickatell(from, resp)
   #   send_clickatell('+2348162522097', "Response sent")
      end
    else  
      render :text => "Refused", :status => 403, :content_type => Mime::TEXT.to_s
    end
  end 
  
   def send_clickatell(num, body)
    user = SiteSetting[:clickatell_user_name]

    pwd =  SiteSetting[:clickatell_password]
    api =  SiteSetting[:clickatell_api_id]
    dest = num.gsub('+', '')
    if (user.blank? || pwd.blank? || api.blank?)
    puts "Error - Clickatell settings not all defined or retrieved"
      return "Error - Clickatell settings not all defined or retrieved"
    end
    uri = "http://api.clickatell.com/http/sendmsg?user=#{user}&password=#{pwd}&api_id=#{api}&to=#{dest}&text=#{URI.escape(body).gsub('.',';')}"
puts "getting #{uri}" if Rails.env.to_s == 'test'
    puts  HTTParty::get uri unless Rails.env.to_s == 'test'  # Careful with testing since this really sends messages!
  end

  def send_twilio(num)  ### NOT FINISHED -- JUST TAKEN FROM AN ONLINE EXAMPLE!
      account = Twilio::RestAccount.new(ACCOUNT_SID, ACCOUNT_TOKEN)

      outgoing = {
          'From' => CALLER_ID,
          'To' => num,
          'Body' => "Test response"
      }

     resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/SMS/Messages",
                               'POST', outgoing)
     puts "#### code: %s\nbody: %s" % [resp.code, resp.body]
   end

private

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
    return true if from == '+16199282591'
    Contact.find_by_phone_1(from) || Contact.find_by_phone_2(from)
  end

end # Class

