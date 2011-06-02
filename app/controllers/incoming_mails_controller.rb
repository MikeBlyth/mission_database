require 'application_helper'
class IncomingMailsController < ApplicationController
  require 'mail'
  skip_before_filter :verify_authenticity_token

  def create  # need the name 'create' to conform with REST defaults, or change routes
#puts "IncomingController create: params=#{params}"
    @mail = Mail.new(params[:message]) # May or may not want to use this
    unless from_member
      render :text => 'Refused--unknown sender', :status => 403, :content_type => Mime::TEXT.to_s
      return
    end
    commands = extract_commands(params['plain'])
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

  # Is this message from someone in our database?
  # (look for a contact record having an email_1 or email_2 matching the message From: header)
  def from_member
    from = params['from']
    matching_contact = Contact.where('email_1 = ? OR email_2 = ?', from, from).first 
    return matching_contact ? matching_contact.member : nil
  end  

  def process_commands(commands)
    successful = true
    from = params['from']
    commands.each do |command|
# puts "**********COMMAND: #{command}"
      case command[0]
        when 'help'
          Notifier.send_help(from).deliver
        when 'test'
          Notifier.send_test(from, 
             "You sent 'test' with parameter string (#{command[1]})").deliver
        when 'info'
          do_info(from, from_member, command[1])
        when 'directory'
          @families = Family.those_on_field_or_active.includes(:members, :residence_location).order("name ASC")
          @visitors = Travel.current_visitors
          output = WhereIsTable.new(:page_size=>Settings.reports.page_size).to_pdf(@families, @visitors, params)
#puts "IncomingMailsController mailing report, params=#{params}"
          Notifier.send_report(from, 
                              Settings.reports.filename_prefix + 'directory.pdf', 
                              output).deliver
        when 'travel'
          selected = Travel.where("date >= ?", Date.today).order("date ASC")
          output = TravelScheduleTable.new(:page_size=>Settings.reports.page_size).to_pdf(selected)
          Notifier.send_report(from, 
                              Settings.reports.filename_prefix + 'travel_schedule.pdf', 
                              output).deliver
        when 'birthdays'
          selected = Member.those_active_sim
          output = BirthdayReport.new(:page_size=>Settings.reports.page_size).to_pdf(selected)
          Notifier.send_report(from, 
                              Settings.reports.filename_prefix + 'birthdays.pdf', 
                              output).deliver
      else
      end # case
    end # commands.each
    return successful    
  end # process_commands

  def do_info(from, from_member, name)
    members = Member.find_with_name(name)
    Notifier.send_info(from, from_member, name, members).deliver
#puts "****** AFTER DELIVER *********"
  end
end # Class

