class Notifier < ActionMailer::Base
  default :from => "database@sim-nigeria.org"
  include ApplicationHelper
  
  def send_test(recipients, content)
    @content = "Test from database@sim-nigeria.org\n\n#{content}"
    mail(:to => recipients, :subject=>'Test from database') do |format|
      format.text {render 'generic'}
    end 
  end

  def send_info(recipients, request, members)
    @content = "Here is the info you requested ('info #{request}'):\n\n"
    if members.empty?
      @content << "No matching members found. Try with first or last name only. Check spelling."
    else
      members.each do |m|
        contact = m.primary_contact
        if contact
          phones = smart_join([format_phone(contact.phone_1), format_phone(contact.phone_2)])
          emails = smart_join([format_phone(contact.email_1), format_phone(contact.email_2)])
        else
          phones = emails = ''
        end 
        @content << "#{m.indexed_name}:\n" +
              "  phone:  #{phones}\n" +
              "  email:  #{emails}\n"
        @content << "  Skype:  #{contact.skype}\n" if !contact.skype.blank? && contact.skype_public 
        @content << "  blog:  #{contact.blog}\n" if contact.blog
        @content << "  photos:  #{contact.photos}\n" if contact.photos
        @content << "  location:  #{m.current_location}\n" if m.current_location(:missing => :nil)
        @content << "  birthday:  #{m.birth_date.to_s(:short)}\n" if m.birth_date
        @content << "\n"
      end
    end
puts "******* Mailing to #{recipients}"
    mail(:to => recipients, :subject=>'Your request for info') do |format|
      format.text {render 'generic'}
    end 
  end

  def travel_mod(recipients)
    @mods = Travel.where("travels.updated_at > ?", Date.today-7.days).includes(:member)
    mail :to => recipients, :subject=>'Travel schedule updates'
  end

  def contact_mod(recipients)
    @greeting = "Hi"
    mail :to => recipients, :subject=>'Contact information updates'
  end

end
