class AdminController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  include ApplicationHelper
  include SessionsHelper
  
  # Do various things to clean the database
  def clean_database
    @report = ''
    clean_members
    clean_families
    flash[:notice] = 'Database cleaned'
  end

private

  def check_linked_value(record, link, record_identifier)
    return "check_linked: invalid attribute #{link} for #{record.class}\n" unless record.respond_to? link
    return '' unless record.send(link).nil?  # returning nil means we found the linked record
    return "Missing or invalid #{link}_id (#{record.send(link.to_s+"_id") || 'nil'}) for #{record.send(record_identifier)}\n"
  end

  # If record has link_id value in "bad", typically [0, nil], then print message and
  # if 'fix' option is true, change the link_id to 'repair_value', usually UNSPECIFIED
  # For example, fix_bad_links(record, :status, [0,nil], true) 
  # would change all nil and 0 values in :status_id to UNSPECIFIED.
  def fix_bad_links(record, link, bad=[0,nil], repair_value=UNSPECIFIED)
    link_value = record.send(link.to_s+'_id')
    if bad.include? link_value
      record.send(link.to_s+"_id=", UNSPECIFIED)
      return "#{link} (#{link_value || 'nil'}) changed to #{repair_value}\n"
    end
    return ''
  end  

  def check_and_fix_link(record, link, record_identifier, bad=[0,nil])
    e = check_linked_value(record, link, record_identifier)
    if !e.blank?
      @report << e 
      @report << fix_bad_links(record, link, bad)
    end  
  end   

  # Describe in detail what things to check and fix in Members table
  def clean_members(fix=false)
    @report << "*** Checking Members ***\n"
    Member.all.each do |m|
      check_and_fix_link(m, :residence_location, :name)
      check_and_fix_link(m, :work_location, :name)
      @report << check_linked_value(m, :family, :name)
      check_and_fix_link(m, :status, :name)
      check_and_fix_link(m, :ministry, :name)
      @report << check_linked_value(m, :spouse, :name) if m.spouse_id
      m.save if (m.changed_attributes.count > 0) & fix
    end # each member
    @report << "\nEnd of Members:"
    @report << (fix ? " fixes made as shown" : " no changes made because 'fix' not specified.")
  end # clean database

  def clean_families(fix=false)
    @report << "*** Checking Families ***\n"
    Family.all.each do |m|
      check_and_fix_link(m, :residence_location, :name)
      check_and_fix_link(m, :head, :name)
      check_and_fix_link(m, :status, :name)
      m.save if (m.changed_attributes.count > 0) & fix
    end # each member
    @report << "\nEnd of Families:"
    @report << (fix ? " fixes made as shown" : " no changes made because 'fix' not specified.")
  end # clean database

end

