class Notifier < ActionMailer::Base
  default :from => "database@sim-nigeria.org"
  include ApplicationHelper
  include IncomingMailsHelper  
  
  def send_help(recipients)
    @content = help_content

    mail(:to => recipients, :subject=>'SIM Nigeria Database Help') do |format|
      format.text {render 'generic'}
      format.html {render 'generic'}
    end 
  end

  def send_test(recipients, content)
    @content = "Test from database@sim-nigeria.org\n\n#{content}"
    mail(:to => recipients, :subject=>'Test from database') do |format|
      format.text {render 'generic'}
    end 
  end

  def send_report(recipients, report_name, report)
#puts "Send Report: recipients=#{recipients}, report_name=#{report_name}"
    @content = "The latest #{report_name} from the #{Settings.site.name} is attached."
    attachments[report_name] = report
    mail(:to => recipients, :subject=>"#{report_name} you requested") do |format|
      format.text {render 'generic'}
    end
  end    

  def send_info(recipients, request, members)
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
          @content << "  phone:  #{phones}\n" + "  email:  #{emails}\n"
          @content << "  Skype:  #{contact.skype}\n" if !contact.skype.blank? && contact.skype_public 
          @content << "  blog:  #{contact.blog}\n" if contact.blog
          @content << "  photos:  #{contact.photos}\n" if contact.photos
        else
          @content << "  ** No contact information available **"
        end 
        @content << "\n"
      end
    end
#puts "******* Mailing to #{recipients}"
    mail(:to => recipients, :subject=>'Your request for info') do |format|
      format.text {render 'generic'}
    end 
  end

  def travel_mod(recipients)
    @mods = Travel.where("travels.updated_at > ?", Date.today-7.days).includes(:member)
    mail :to => recipients, :subject=>'Travel schedule updates'
  end

end
