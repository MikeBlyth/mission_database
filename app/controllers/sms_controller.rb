#require 'sms-rb'
require 'twiliolib'
#require 'sms-rb'

class SmsController < ApplicationController
  skip_before_filter :verify_authenticity_token

#(415) 599-2671	PIN 9501-1019
#http://demo.twilio.com/welcome/sms

# Twilio REST API version 
API_VERSION = '2010-04-01'
# Twilio AccountSid and AuthToken
ACCOUNT_SID = 'ACe9b242ff1c3e1a3c03e8b283eba854f0'
ACCOUNT_TOKEN = '095bc832b449ffb9fb503d6b94ae00fe'

# Outgoing Caller ID previously validated with Twilio
CALLER_ID = '+14155992671';




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
member = Member.find_by_last_name(body.strip)
resp = member ? "#{member.full_name_short} is at #{member.current_location}" : "Unknown '#{body.strip}'"
      render :text => resp, :status => 200, :content_type => Mime::TEXT.to_s
    else  
      render :text => "Refused", :status => 403, :content_type => Mime::TEXT.to_s
    end
  end 
  
#  def index  # need the name 'create' to conform with REST defaults, or change routes
##puts "IncomingController create: params=#{params}"
## SMS.text("*SQUAWK* #{params[:body]} *SQUAWK*", :to => params[:from])
##puts "Received msg on index with params #{params}"
#    if from_member
#      CalendarEvent.create(:date=>Time.now, :event => "Received msg on index with params #{params}"[0,240])
#    else  
#    end
##    render :nothing=>true
#      render :text => "Success", :status => 200, :content_type => Mime::TEXT.to_s
#  end 
#  
  
  def send_a_page(num)
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

  def from_member(from) 
    return true if from == '+16199282591'
    Contact.find_by_phone_1(from) || Contact.find_by_phone_2(from)
  end

end # Class

