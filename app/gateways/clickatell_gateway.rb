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

  ClickatellStatusCodes = {
    1 => {:our_status=>-1, :description=>"The message ID is incorrect or reporting is delayed."},
    2 => {:our_status=>1, :description=>"The message could not be delivered and has been queued for attempted redelivery."},
    3 => {:our_status=>1, :description=>"Delivered to gateway."},
    4 => {:our_status=>2, :description=>"Received by handset."},
    5 => {:our_status=>-1, :description=>"Error with message, likely problem with content"},
    6 => {:our_status=>-1, :description=>"User canceled delivery"},
    7 => {:our_status=>-1, :description=>"Error with message"},
    8 => {:our_status=>1, :description=>"Message received by gateway."},
    9 => {:our_status=>-1, :description=>"Routing error"},
    10 => {:our_status=>-1, :description=>"Message expired"},
    11 => {:our_status=>-1, :description=>"Message queued for later delivery"},
    12 => {:our_status=>-1, :description=>"Out of credit"},
    14 => {:our_status=>-1, :description=>"Maximum MT limit exceeded"}
    }

  def initialize
    @gateway_name = 'clickatell'
    @required_params = [:user_name, :password, :api_id]
    super
  end

  # Send a message (@body) to a phone (@number)
  # If using a RESTFUL interface or other where a URI is called, you can follow this model. Otherwise,
  # this method will have to do whatever needed to tell the gateway service to send the message.
  def deliver(number=@number, body=@body)
#puts "***** CGtw#deliver"
    number.sub!('+', '')  # Clickatell may not like '+' prefix
    clickatell_base_uri = "http://api.clickatell.com/http/sendmsg"
    @uri = clickatell_base_uri + "?user=#{@user_name}&password=#{@password}&api_id=#{@api_id}&to=#{number}&text=#{URI.escape(body)}"
    @http_status =  HTTParty::get @uri #unless Rails.env.to_s == 'test'  # Careful with testing since this really sends messages!
#puts "**** CGtw#deliver @http_status=#{@http_status}"
    super
  end

  def self.parse_status_params(params)
    gateway_msg_id = params[:apiMsgId]
    status = decode_status(params[:status])
    return {:gateway_msg_id => gateway_msg_id, :updates=>{:status=>status}}
  end

  def self.decode_status(gateway_reported_status)
    return ClickatellStatusCodes[gateway_reported_status.to_i][:our_status]
  end
end  

