require 'twiliolib'
require 'application_helper'
include ApplicationHelper
require 'httparty'
require 'uri'

# Convenient way to send SMS. 
# * Extracts parameters from the SiteSettings upon initialization
# * Gives error if any of the required settings are not found
# * provides stub "send" method which saves body and phone number to instance variables and generates log entry
#
# * SmsGateway itself is not functional; actual sending must be defined in the sub-class
#   such as ClickatellGateway.
#
# Example:
#   gateway = ClickatellGateway.new
#   if gateway.status[:errors] 
#     (handle setup problem; probably some parameters are missing from the setup/configuration)
#   end
#   gateway.send("+2345551111111", "Security alert!")
#   if gateway.status == ...
#
# See class definition of ClickatellGateway as an example of how to define a new gateway. 
#
class SmsGateway
  attr_accessor :number, :body, :required_params
  attr_reader :uri, :http_status, :gateway_name, :errors

  def initialize
    get_required_params if @required_params && !@required_params.empty?
    @gateway_name ||= 'SmsGateway'
  end

  def get_required_params
    missing = []
    @required_params.each do |param|
      param_value = get_site_setting(param)
      if param_value.nil?
        missing << param
      else
        self.instance_variable_set "@#{param.to_s}", param_value
      end
    end
    unless missing.empty?
      @errors ||= []
      @errors << missing.join(', ')
    end
  end
      
  def get_site_setting(setting)
    begin
      return SiteSetting.send "#{@gateway_name}_#{setting}".to_sym
    rescue
      return nil
    end      
  end      

  def send(number=@number, body=@body)
    @number=number
    @body=body
    AppLog.create(:code => "SMS.sent.#{@gateway_name}", :description=>"to #{@number}: #{@body[0..30]}, resp=#{@http_status}")
  end
end

# Actual usable gateways are subclassed from SmsGateway.
# 
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
  def send(number=@number, body=@body)
    number.sub!('+', '')  # Clickatell may not like '+' prefix
    clickatell_base_uri = "http://api.clickatell.com/http/sendmsg"
    @uri = clickatell_base_uri + "?user=#{@user_name}&password=#{@password}&api_id=#{@api_id}&to=#{number}&text=#{URI.escape(body)}"
    @http_status =  HTTParty::get @uri #unless Rails.env.to_s == 'test'  # Careful with testing since this really sends messages!
    super
  end

end  

