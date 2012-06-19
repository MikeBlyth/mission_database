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
    @from_address = params['from']
    @body = params['plain']
    commands = extract_commands(@body)
    if commands.nil? || commands.empty?
      Notifier.send_generic(@from_address, "Error: nothing found in your message #{@body[0..160]}")
      success = false
    else
puts "**** commands=#{commands}"
      success = process_commands(commands)
    end

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
    @from_member = matching_contact ? matching_contact.member : nil
  end  

  def process_commands(commands)
    successful = true
    from = params['from']
    # Special case for command 'd' = distribute to one or more groups, because the rest of the 
    #   body will be sent without scanning for further commands
    if commands[0][0] == 'd'  # distribute
      result = group_deliver(@body)
      Notifier.send_generic(from, result).deliver  # Let the sender know success, errors, etc.
      return successful
    end
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

  def group_deliver(text)
    unless text =~ /\A\s*d\s+(.*):\s*(.*)/  # "d <groups>: <body>..."  (body is multipline)
      return("I don't understand. To send to groups, separate the group names with spaces" +
             " and be sure to follow the group or groups with a colon (':').")
    end
    body = $2   # All the rest of the message, from match above (text =~ ...)
    group_names_string = $1
    group_names = group_names_string.gsub(/;|,/, ' ').split(/\s+/)  # e.g. ['security', 'admin']
    group_ids = Group.ids_from_names(group_names)   # e.g. [1, 5]
    valid_group_ids = group_ids.map {|g| g if g.is_a? Integer}.compact
    valid_group_names = valid_group_ids.map{|g| Group.find(g).group_name}
    invalid_group_names = group_ids - valid_group_ids   # This will be names of any groups not found
    if valid_group_ids.empty?
      return("You sent the \"d\" command which means to forward the message to groups, but " +
          "no valid group names or abbreviations found in \"#{group_names_string}.\" ")
    end
    sender_name = @from_member.full_name_short
    message = Message.new(:send_sms=>false, :send_email=>true, 
                          :to_groups=>valid_group_ids, :body=>@body)
    # message.deliver  # Don't forget to deliver!
    confirmation = "Your message #{body[0..120]} was sent to groups #{valid_group_names.join(', ')}. "
    unless invalid_group_names.empty?
      if invalid_group_names.size == 1
        confirmation << "Group #{invalid_group_names} was not found, so did not receive messages."
      else
        confirmation << "Groups #{invalid_group_names.join(', ')} were not found, so did not receive messages."
      end
    end
    return confirmation
  end

end # Class

