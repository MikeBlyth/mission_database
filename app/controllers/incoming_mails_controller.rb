class IncomingMailsController < ApplicationController
  require 'mail'
  skip_before_filter :verify_authenticity_token

  def create  # need the name 'create' to conform with REST defaults, or change routes
#puts "IncomingController create: params=#{params}"
    @mail = Mail.new(params[:message]) # May or may not want to use this
    unless from_member?
      render :text => 'Refused--unknown sender', :status => 403, :content_type => Mime::TEXT.to_s
      return
    end
    commands = extract_commands
    success = process_commands(commands)

    # if the message was handled successfully then send a status of 200,
    #   else give a 422 with the errors
    if success
      render :text => "Success", :status => 200, :content_type => Mime::TEXT.to_s
    else
      render :text => 'Error: Email commands not recogized', :status => 422, :content_type => Mime::TEXT.to_s
    end
  end # create

private

  # with incoming body like
  #   COMMAND_1 
  #   command_2 Parameters for this command 
  #   ...
  # make array like [ [command_1, ''], [command_2, 'Parameters for this command']]
  def extract_commands
    commands = params['plain'].lines.map do |line| 
      line =~ /\s*(\w+)( .*)?/ 
      [($1 || '').downcase, ($2 || '').strip.chomp]
    end  
# puts "*** Commands = #{commands}"
    return commands
  end
  
  # Is this message from someone in our database?
  # (look for a contact record having an email_1 or email_2 matching the message From: header)
  def from_member?
    from = params['from']
    return !Contact.find_by_email_1(from).nil? || !Contact.find_by_email_2(from).nil?
  end  

  def process_commands(commands)
    successful = true
    from = params['from']
    commands.each do |command|
# puts "**********COMMAND: #{command}"
      case command[0]
        when 'test'
          Notifier.send_test(from, 
             "You sent 'test' with parameter string (#{command[1]})").deliver
        when 'info'
          do_info(from, command[1])
      else
      end # case
    end # commands.each
    return successful    
  end # process_commands

  def do_info(from, name)
    members = Member.find_with_name(name)
    Notifier.send_info(from, name, members).deliver
#puts "****** AFTER DELIVER *********"
  end
end # Class

