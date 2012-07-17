require 'twilio-ruby'
require 'application_helper'
include ApplicationHelper
require 'httparty'
require 'uri'

# This is a thin wrapper around twilio-ruby to make it compatible with the "Gateway" class
# See https://github.com/twilio/twilio-ruby/wiki

class TwilioGateway < SmsGateway
  # Initialize method should set the name of this gateway and list all the needed parameters.
  # Parent SmsGateway initialization will set instance variables corresponding to those parameters.
  # In this ClickatellGateway class, then, after initialization we will have @user_name, @password, and @api_id
  # extracted from the SiteSettings.
  # The initialize method could also set those variables itself (but then they won't be accessible to users)

  def initialize
    @gateway_name = 'twilio'
    @required_params = [:account_sid, :auth_token, :phone_number]  # "twilio_" is automatically prefixed to these for looking in the site settings
    @client = Twilio::REST::Client.new account_sid, auth_token
    super
  end

  # send an sms using Twilio-ruby interface
  # No error checking done in this method. Should eventually be added.
  #   See http://www.twilio.com/docs/api/rest/sending-sms for how to do status callbacks
  def deliver(numbers=@numbers, body=@body)
    @numbers = numbers  # Update instance variables (matters only if they were not included as arguments)
    @body = body        #  ...
    outgoing_numbers = numbers_to_string_list
    @numbers.each do |number|
      @client.account.sms.messages.create(
        :from => @phone_number,
        :to => number.to_s,
        :body => @body
      )
    end
    @gateway_reply = '' # Since we're not getting one with this interface
    super
  end

end  

