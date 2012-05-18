class AdminController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_admin #, :only => [:edit, :update]
  include AuthenticationHelper
  include ApplicationHelper
  include SessionsHelper
  layout 'application'

  def self.daily
    puts "This is the daily job runner"
    autosend_travel_reminders
    self.weekly if Date.today.wday == 0
  end
  
  def self.weekly
    autosend_contact_updates
    autosend_travel_updates
  end

  def self.autosend_contact_updates
    contacts = Contact.recently_updated.sort
    recipients = SiteSetting.contact_update_recipients
    message = Notifier.contact_updates(recipients, contacts)
    message.deliver
    AppLog.create(:severity=>'info', :code=>'Notice.contact_updates', 
      :description => "#{contacts.length} updated contacts")
  end

  def self.autosend_travel_reminders
    travels = Travel.pending.where("reminder_sent IS ?", nil)
    messages = []
    travels.each do |travel|
      if travel.member.email
        messages << Notifier.travel_reminder(travel)  
        travel.update_attribute(:reminder_sent, Date.today)
      end
    end
    messages.each {|m| m.deliver}
    AppLog.create(:severity=>'info', :code=>'Notice.travel_reminder', 
        :description => "sent #{messages.length} messages")
  end

  def self.autosend_travel_updates
    recipients=SiteSetting[:travel_update_recipients]
    travel_updates = Travel.recently_updated.includes(:member)
    notice = Notifier.travel_updates(recipients, travel_updates)
    notice.deliver
    AppLog.create(:severity=>'info', :code=>'Notice.travel_updates', 
      :description => "#{travel_updates.length} updated travels")
  end  

  # Do various things to clean the database
  def clean_database
    @title = "Clean database"
    fix = params[:fix]=='true'  # This boolean determines whether we actually make changes to the database
    cum_report = ""
    cum_report << clean_members(fix)
    cum_report << clean_families(fix)
    cum_report << clean_locations(fix)
    cum_report << clean_field_terms(fix)
    cum_report << clean_contacts(fix)
    flash[:notice] = fix ? 'Database cleaned' : 'Report only; database not yet cleaned'
    @report = cum_report
    AppLog.create(:severity=>'info', :code=>'CleanDatabase', :description => "Fixed = #{fix}")
  end

  def email_addresses(s)
    (s || '').split(';').map {|address| address.strip}
  end

  def review_travel_updates
    @title = 'Travel updates'
    @travel_updates = Travel.recently_updated.includes(:member).where('DATE >= ?', Date.today)
    render :template=>'notifier/travel_updates' 
  end  

  def send_travel_updates
    recipients=email_addresses(SiteSetting[:travel_update_recipients])
    if recipients.empty?
      flash[:notice] = "No recipients defined in settings 'Travel Update Recipients.'"
    else
      @travel_updates = Travel.recently_updated.includes(:member).where('DATE >= ?', Date.today)
      @notice = Notifier.travel_updates(recipients, @travel_updates)
      @notice.deliver
  #puts "Notice=#{@notice}"
      flash[:notice] = "Sent #{recipients.length} notices."
    end
    AppLog.create(:severity=>'info', :code=>'Notice.travel_updates', 
      :description => "#{@travel_updates.length} updated travels, sent to #{recipients.length} recipients")
    redirect_to travels_path
  end  

  def review_travel_reminders
    @title = 'Travel reminders'
    @travels = Travel.pending.where("reminder_sent IS ? AND member_id IS NOT ?", nil, nil)
  end
    
  # This actually MAILS the travel reminders after they've been approved.
  def send_travel_reminders
    @title = 'Send reminders'
    @travels = Travel.pending.where("reminder_sent IS ? AND member_id IS NOT ?", nil, nil)
    @messages = []
    @travels.each do |travel|
      if travel.member.email
        @messages << Notifier.travel_reminder(travel)  
        travel.update_attribute(:reminder_sent, Date.today)
#puts "**Reminder_sent set to #{travel.reload.reminder_sent}"
      end
    end
    @messages.each {|m| m.deliver}
    flash[:notice] = "Sent #{@messages.count} travel reminder messages"
    AppLog.create(:severity=>'info', :code=>'Notice.travel_reminder', :description => flash[:notice])
    redirect_to travels_path
  end

  def review_family_summaries
    @title = 'Family data summaries'
    date_selection_filter = ["summary_sent IS ? OR (? - summary_sent) > ?", nil,
         Date.today, Settings.family.info_summary_interval]
    @families= Family.those_active.where(date_selection_filter).sort
  end
    
  # This actually MAILS the summaries after they've been approved.
  def send_family_summaries
    @title = 'Send summaries'
    date_selection_filter = ["summary_sent IS ? OR (? - summary_sent) > ?", nil,
         Date.today, Settings.family.info_summary_interval]
    recipients = Family.those_active.where(date_selection_filter)
    @messages = []
    recipients.each do |family|
      if family.email
        @messages << Notifier.send_family_summary(family)  
        family.update_attribute(:summary_sent, Date.today)
#puts "**Summary_sent set to #{family.reload.summary_sent}"
      end
    end
    @messages.each {|m| m.deliver}
    flash[:notice] = "Sent #{@messages.count} family summary messages"
    redirect_to families_path
  end

  def before_report(title)
    @report = "\n\n<strong>*** Checking #{title} ***</strong>\n"
    @orig_report_length = @report.length
  end
  
  def after_report(title, fix)
    final_report_length = @report.length
    @report << "\nEnd of #{title}: "
    if final_report_length == @orig_report_length  # No additions to report means no errors
      @report << " no errors found"
    else  
      @report << (fix ? "fixes made as shown.\n" : " no changes made because 'fix' not specified.\n")
    end
  end  
  
  # Describe in detail what things to check and fix in Members table
  def clean_members(fix=false)
    before_report 'Members'
    Member.all.each do |m|
  #*    check_and_fix_link(m, :residence_location, m.name)
      check_and_fix_link(m, :work_location, m.name)
      check_and_fix_link(m, :family, m.name)
      check_and_fix_link(m, :status, m.name)
      check_and_fix_link(m, :spouse, m.name)
      check_and_fix_link(m, :country, m.name)
      check_and_fix_link(m, :ministry, m.name)
      p = m.personnel_data
      if p
        check_and_fix_link(p, :employment_status, m.name)
        check_and_fix_link(p, :education, m.name)
        p.save if p.changed? & fix
      end
      m.update_record_without_timestamping  if m.changed? & fix
    end # each member
    after_report 'Members', fix
  end # clean members

  def clean_families(fix=false)
    before_report 'Families'
    Family.all.each do |m|
      check_and_fix_link(m, :residence_location, m.name)
      check_and_fix_link(m, :head, m.name)
      check_and_fix_link(m, :status, m.name)
      Family.record_timestamps = false
      m.save if (m.changed_attributes.count > 0) & fix
      Family.record_timestamps = true
    end # each member
    after_report 'Families', fix
  end # clean families

  def clean_locations(fix=false)
    before_report 'Locations'
    orphans = find_orphans(:location, :city)  # Any locations that do not belong to a valid city
    orphans.all.each do |loc|
      @report << "Location #{loc} has city_id= #{loc.city_id} which is not a valid city; fix manually."
    end
#    Location.all.each do |m|
#      check_and_fix_link(m, :city, :description)
#      m.save if (m.changed_attributes.count > 0) & fix
#    end # each location
    after_report 'Locations', fix
  end # clean locations

  def clean_field_terms(fix=false)
    before_report 'Field Terms'
    empty_terms = FieldTerm.where(:start_date=>nil, :end_date=>nil)
    @report << "There are #{empty_terms.count} 'empty' field term records (no dates) to be deleted.\n\n" unless
      empty_terms.empty?
    empty_terms.delete_all if fix
    orphans = find_orphans(:field_term, :member)
    @report << "There are #{orphans.count} orphaned Field Term records (not belonging to an existing member).\n" + 
        "\tThese will be deleted if 'fix' is specified.\n\n" unless orphans.empty?
    orphans.destroy_all if fix
    FieldTerm.all.each do |m|
      name = m.member ? m.member.name : 'Unknown member'
      check_and_fix_link(m, :employment_status, name)
      check_and_fix_link(m, :primary_work_location, name)
      check_and_fix_link(m, :ministry, name)
      FieldTerm.record_timestamps = false
      m.save if (m.changed_attributes.count > 0) & fix
      FieldTerm.record_timestamps = true
    end # each field term
    after_report 'Field Terms', fix
  end # clean field terms

  def clean_contacts(fix=false)
    before_report 'Contacts'
    report_destroy_orphans(:contact, :member, fix)
    Contact.all.each do |m|
      trim_email_addresses(m)
      standardize_phone_numbers(m)
      check_and_fix_link(m, :contact_type, (m.member ? m.member.name : "Unknown member"))
      Contact.record_timestamps = false
      m.save if (m.changed_attributes.count > 0) & fix
      Contact.record_timestamps = true
    end # each location
    after_report 'Contacts', fix
  end # clean contacts

  def clean_travel
   # Nothing to do? These do not even need a member_id since they may belong to guests
  end 

#private

  # Remember not to use update_attribute since it will change the record regardless of the
  # value of 'fix' and will also result in more database accesses. Instead, just set the 
  # link_id using =, and the main cleaner method will save the record after all the changes
  # are made, if 'fix' is true.

  # Check for the presence of associated record 'link'
  # * record = source record we're checking, e.g. member
  # * link = association, e.g. :status if we're looking for the status of this member
  # * record_identifier = method/attribute used to identify record, e.g. :name or :description
  #   (for reporting purposes)
  # Returns empty string if valid, error message otherwise
  def check_linked_value(record, link, record_identifier)
#puts "***Check_linked_value(#{record.class}, #{link}, #{link_value(record, link)}"
    # Make sure record includes (responds to) this association
    raise "check_linked called with invalid attribute #{link} for #{record.class}\n" unless record.respond_to? link
    # Return empty string (no error) if _id is nil or _id points to an existing record
    return nil if link_value(record, link).nil? || record.send(link) 
    return "Invalid #{link}_id (#{link_value(record, link) || 'nil'}) for #{record_identifier}\n"
  end

  # If record has link_id value in "bad", typically [0, nil], then print message.
  # Change the link_id to 'repair_value'. (new values are saved only if 'fix' is specified)
  # For example, fix_bad_links(record, :status, [0,nil], true) 
  # would change all nil and 0 values in :status_id to UNSPECIFIED.
  def delete_bad_link(record, link)
    record.send(link.to_s+"_id=", nil)
#@report << "Delete bad link: #{link.to_s+'_id='}nil, changed? = #{record.changed?}\n"
  end  

  # Find all records in child table that do not have valid to parent.
  # For example, to find all travel records that do not belong to any member,
  #    find_orphans(:travel, :members). 
  # Plural or singular, string or symbol are all accepted and appropriately converted.
  # Caution! This deletes the records themselves, unlike check_and_fix_link which simply
  # nils the particular invalid link. delete_orphans is designed for handling orphaned
  # _detail_ records such as contacts and field_terms rather than the parent records 
  # such as family and member.
  def find_orphans(child, parent)
    child_model = child.to_s.singularize.camelize.constantize
    parent_singular = parent.to_s.singularize
    parent_plural = parent.to_s.pluralize
    orphans = child_model.joins("LEFT OUTER JOIN #{parent_plural} ON #{parent_plural}.id = #{parent_singular}_id").
      where("#{parent_plural}.id is NULL")  
    return orphans
  end

  def report_destroy_orphans(child, parent, fix)
    orphans = find_orphans(child, parent)
    @report << "There are #{orphans.count} orphaned #{child.to_s} records (not belonging to an #{parent.to_s}).\n" + 
        "\tThese will be deleted if 'fix' is specified.\n\n"  unless orphans.empty?
    orphans.destroy_all if fix
  end

  # Check validity of the association "link" for "record", 
  def check_and_fix_link(record, link, record_identifier)
    error = check_linked_value(record, link, record_identifier)
    if error
      @report << error
      @report << "\t#{link} (#{link_value(record, link)}) deleted (changed to nil).\n"
      delete_bad_link(record,link)
    end  
  end
  
  def standardize_phone_numbers(record)
    phones = [record.phone_1, record.phone_2]
    standardized = phones.map {|p| p.phone_std if p}
#    std_1, std_2 = (record.phone_1.phone_std if record.phone_1), (record.phone_2.phone_std if record.phone_2)
    if standardized != phones
      @report << "Standardized phone number(s) for  #{record.member.name}: #{record.phone_1 || 'nil'}/#{record.phone_2 || 'nil'}=>#{standardized[0] || 'nil'}/#{standardized[1] || 'nil'}\n"
      record.phone_1, record.phone_2 = standardized
    end
    standardized.each do |p|
      if p && p[0] != '+'
        @report << "<strong>***Phone number #{p} for #{record.member.name} is missing country code: not fixed!</strong>\n"
      end
    end
  end       

  def trim_email_addresses(record)
    stripped_1, stripped_2 = (record.email_1).strip, record.email_2.strip
    if [stripped_1, stripped_2] != [record.email_1, record.email_2]
      @report << "Fix leading/trailing blanks in email address for #{record.member.name}\n"
      record.email_1, record.email_2 = stripped_1, stripped_2
    end
  end
end

