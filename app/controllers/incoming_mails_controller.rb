class IncomingMailsController < ApplicationController
  require 'mail'
  skip_before_filter :verify_authenticity_token

   def create
puts "IncomingController create: params=#{params}"
     incoming_handled = Incoming.receive(Mail.new(params[:message]))
x = Mail.new(params[:message])
puts x.awesome_inspect
     # if the message was handled successfully then send a status of 201,
     #   else give a 422 with the errors
     if incoming_handled
      render :text => "Success", :status => 201, :content_type => Mime::TEXT.to_s
    else
      render :text => 'Error: Email commands not recogized', :status => 422, :content_type => Mime::TEXT.to_s
   end
  end
end

#class IncomingMailsController < ApplicationController    
#  require 'mail'
#  skip_before_filter :verify_authenticity_token

#  def create
#    message = Mail.new(params[:message])
#    Rails.logger.log message.subject #print the subject to the logs
#    Rails.logger.log message.body.decoded #print the decoded body to the logs
#    Rails.logger.log message.attachments.first.inspect #inspect the first attachment

#    # Do some other stuff with the mail message

#    render :text => 'success', :status => 200 # a status of 404 would reject the mail
#  end
#end

