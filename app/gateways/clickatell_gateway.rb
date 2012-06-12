require 'twiliolib'
require 'application_helper'
include ApplicationHelper
require 'httparty'
require 'uri'

class ClickatellGateway < SmsGateway
  # Initialize method should set the name of this gateway and list all the needed parameters.
  # Parent SmsGateway initialization will set instance variables corresponding to those parameters.
  # In this ClickatellGateway class, then, after initialization we will have @user_name, @password, and @api_id
  # extracted from the SiteSettings.
  # The initialize method could also set those variables itself (but then they won't be accessible to users)
  def initialize
    @gateway_name = 'clickatell'
    @required_params = [:user_name, :password, :api_id]
    super
  end

  # Send a message (@body) to a phone (@number)
  # If using a RESTFUL interface or other where a URI is called, you can follow this model. Otherwise,
  # this method will have to do whatever needed to tell the gateway service to send the message.
  def deliver(number=@number, body=@body)
    number.sub!('+', '')  # Clickatell may not like '+' prefix
    clickatell_base_uri = "http://api.clickatell.com/http/sendmsg"
    @uri = clickatell_base_uri + "?user=#{@user_name}&password=#{@password}&api_id=#{@api_id}&to=#{number}&text=#{URI.escape(body)}"
    @http_status =  HTTParty::get @uri #unless Rails.env.to_s == 'test'  # Careful with testing since this really sends messages!
    super
  end

end  

