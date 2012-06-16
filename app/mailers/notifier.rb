class Notifier < ActionMailer::Base
  default :from => "database@sim-nigeria.org"
  include ApplicationHelper
  include IncomingMailsHelper  
  include NotifierHelper
    
# Question: we use something like Notifier.send_help to get a message. This looks like 
# and instance method, so how can we call it for Notifier? Why don't we have to define
# send_help as a class method?

  def travel_reminder(travel)
    return nil unless travel.member   # If no member, then no one to mail notice to!
    @content = travel_reminder_content(travel)
    email = travel.member.email
    msg = mail(:to => email,
               :cc => 'mjblyth@gmail.com', #Settings.email.travel,
               :from=>Settings.email.travel,
               :subject=>'Confirming your travel arrangements') do |format|
      format.text {render 'generic'}
      format.html {render 'generic'}
    end
  end

  def send_help(recipients)
    @content = help_content

    mail(:to => recipients, :subject=>'SIM Nigeria Database Help') do |format|
      format.text {render 'generic'}
      format.html {render 'generic'}
    end 
  end

  # Create messages to each recipient family summarizing their database content.
  # Contents of message is generated by family_summary_content in notifier_helper.rb
  def send_family_summary(family)
  #puts "Processing #{family ? family.name : "NIL"} for summary"
    @content = family_summary_content(family)
    msg = mail(:to => family.email, 
               :cc => 'mike.blyth@sim.org',
               :from => 'mike.blyth@sim.org',
                :subject=>'Your SIM Nigeria Database Information') do |format|
      format.text {render 'generic'}
      format.html {render 'generic'}
    end
  end

  def send_test(recipients, content)
    @content = "Test from database@sim-nigeria.org\n\n#{content}"
    mail(:to => recipients, :subject=>'Test from database') do |format|
      format.text {render 'generic'}
      format.html {render 'generic'}
    end 
  end

  def send_generic(recipients, content, bcc=false)
#puts "**** send_generic recipients=#{recipients}, content=#{content}"
    @content = content
    mail(
      :to => (bcc ? '' : recipients),
      :bcc => (bcc ? recipients : ''), 
      :subject=>'Message from SIM Nigeria'
                                           ) do |format|
      format.text {render 'generic'}
      format.html {render 'generic'}
    end 
  end

  def send_report(recipients, report_name, report)
  #puts "Send Report: recipients=#{recipients}, report_name=#{report_name}"
    @content = "The latest #{report_name} from the #{Settings.site.name} is attached."
    attachments[report_name] = report
    mail(:to => recipients, :subject=>"#{report_name} you requested") do |format|
      format.text {render 'generic'}
      format.html {render 'generic'}
    end
  end    

  # TODO: should be able to use contact.summary here for all the contact info.
  def send_info(recipients, from_member, request, members)
    @content = "Here is the info you requested ('info #{request}'):\n\n"
    if members.empty?
      @content << "No matching members found. Try with first or last name only. Check spelling.\n" +
                  "Names must be properly capitalized like 'Jones' not 'jones' or 'JONES'."
    else
      members.each do |m|
        contact = m.primary_contact
        @content << "#{m.indexed_name}:\n" 
        @content << "  location:  #{m.current_location}\n" if m.current_location(:missing => :nil)
        @content << "  birthday:  #{m.birth_date.to_s(:short)}\n" if m.birth_date
        if contact
          phones = smart_join([format_phone(contact.phone_1), format_phone(contact.phone_2)])
          emails = smart_join([format_phone(contact.email_1), format_phone(contact.email_2)])
          @content << "  phone:  #{phones}\n" unless phones.blank? || contact.phone_private
          @content << "  email:  #{emails}\n" unless phones.blank? || contact.email_private
          @content << "  Skype:  #{contact.skype}\n" unless contact.skype.blank? || contact.skype_private
          @content << "  phone:  #{phones} (private!)\n" if (m == from_member) && contact.phone_private
          @content << "  email:  #{emails} (private!)\n" if (m == from_member) && contact.email_private
          @content << "  Skype:  #{contact.skype} (private!)\n" if (m == from_member) && contact.skype_private
          @content << "  blog:  #{contact.blog}\n" if contact.blog
          @content << "  photos:  #{contact.photos}\n" if contact.photos
        else
          @content << "  ** No contact information available **"
        end 
        @content << "\n"
      end
    end
    mail(:to => recipients, :subject=>'Your request for info') do |format|
      format.text {render 'generic'}
      format.html {render 'generic'}
    end 
  end

  def contact_updates(recipients, contacts)
    @content = "--Content--"  # This is not used -- take it out?
    @contacts = contacts
    @email = true # Same template used for screen display (check) & actual mailing, so @email is
                  # used to flag that we are emailing msg. So we don't include the "Send" button.
    mail(:to => recipients, :subject=>'Recently updated contact info') do |format|
      format.text {render 'reports/contact_updates'}
      format.html {render 'reports/contact_updates'}
    end 
  end

  def travel_updates(recipients, travel_updates)
    @travel_updates = travel_updates
    @email = true
    mail :to => recipients, :subject=>'Travel schedule updates'
  end

end
