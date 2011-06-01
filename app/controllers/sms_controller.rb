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
# SMS.text("*SQUAWK* #{params[:body]} *SQUAWK*", :to => params[:from])
    CalendarEvent.create(:date=>Time.now, :event => "Received msg with params #{params}")
puts "Received msg on create with params #{params}"
    if from_member
      render :text => "Success", :status => 200, :content_type => Mime::TEXT.to_s
      CalendarEvent.create(:date=>Time.now, :event => "Received msg on create with params #{params}")
    else  
      render :text => "Refused", :status => 403, :content_type => Mime::TEXT.to_s
    end
  end 
  
  def index  # need the name 'create' to conform with REST defaults, or change routes
#puts "IncomingController create: params=#{params}"
# SMS.text("*SQUAWK* #{params[:body]} *SQUAWK*", :to => params[:from])
    CalendarEvent.create(:date=>Time.now, :event => "Received msg on index with params #{params}")
puts "Received msg on index with params #{params}"
    if from_member
      render :text => "Success", :status => 200, :content_type => Mime::TEXT.to_s
      CalendarEvent.create(:date=>Time.now, :event => "Received msg with params #{params}")
    else  
      render :text => "Refused", :status => 403, :content_type => Mime::TEXT.to_s
    end
  end 
  
  
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

  def from_member  
    return true
    Contact.find_by_phone_1(params[:from]) || Contact.find_by_phone_2(params[:from])
  end

end # Class

