class AdminController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_admin #, :only => [:edit, :update]
  include AuthenticationHelper
  include ApplicationHelper
  include SessionsHelper
  
  # Do various things to clean the database
  def clean_database
    fix = params[:fix]=='true'  # This boolean determines whether we actually make changes to the database
    cum_report = ""
    cum_report << clean_members(fix)
    cum_report << clean_families(fix)
    cum_report << clean_locations(fix)
    cum_report << clean_field_terms(fix)
    cum_report << clean_contacts(fix)
    flash[:notice] = fix ? 'Database cleaned' : 'Report only; database not yet cleaned'
    @report = cum_report
  end

  def before_report(title)
    @report = "\n<strong>*** Checking #{title} ***</strong>"
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
      check_and_fix_link(m, :residence_location, m.name)
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
      end
      m.save if (m.changed_attributes.count > 0) & fix
    end # each member
    after_report 'Members', fix
  end # clean members

  def clean_families(fix=false)
    before_report 'Families'
    Family.all.each do |m|
      check_and_fix_link(m, :residence_location, m.name)
      check_and_fix_link(m, :head, m.name)
      check_and_fix_link(m, :status, m.name)
      m.save if (m.changed_attributes.count > 0) & fix
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
    empty_terms = FieldTerm.where(:start_date=>nil, :end_date=>nil, :est_start_date=>nil, :est_end_date=>nil)
    @report << "There are #{empty_terms.count} 'empty' field term records (no dates) to be deleted.\n\n" unless
      empty_terms.empty?
    orphans = find_orphans(:field_term, :member)
    @report << "There are #{orphans.count} orphaned Field Term records (not belonging to an existing member).\n" + 
        "\tThese will be deleted if 'fix' is specified.\n\n"
    orphans.destroy_all if fix
    FieldTerm.all.each do |m|
      name = m.member ? m.member.name : 'Unknown member'
      check_and_fix_link(m, :employment_status, name)
      check_and_fix_link(m, :primary_work_location, name)
      check_and_fix_link(m, :ministry, name)
      m.save if (m.changed_attributes.count > 0) & fix
    end # each field term
    after_report 'Field Terms', fix
  end # clean field terms

  def clean_contacts(fix=false)
    before_report 'Contacts'
    report_destroy_orphans(:contact, :member, fix)
    Contact.all.each do |m|
      check_and_fix_link(m, :contact_type, (m.member ? m.member.name : "Unkown member"))
      m.save if (m.changed_attributes.count > 0) & fix
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
        "\tThese will be deleted if 'fix' is specified.\n\n"
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

end

