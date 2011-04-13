class ReorgStatuses < ActiveRecord::Migration

  def self.reorg(member)
    changed = false
    if member.status.nil? || member.status.description.nil?
      puts "**** Bad status for #{member.name}"
      return
    end
    case member.status_id
      when @alumni
        member.status_id = @inactive
        member.family.status_id = @inactive
        member.family.status.save
#        member.personnel_data.employment_status_id = @e_sim_alumni
        changed = true
      when @college, @mkadult
        member.status_id = @inactive
        member.personnel_data.employment_status_id = @e_mk_adult
        changed = true
      when @mkalumni
        member.status_id = @inactive
        member.personnel_data.employment_status_id = @e_mk_dependent
        changed = true
      when @mkfield
        member.status_id = @field
        member.personnel_data.employment_status_id = @e_mk_dependent
        changed = true
      when @retired
        member.status_id = @inactive
        member.personnel_data.employment_status_id = @e_sim_retired
        member.family.status_id = @inactive
        member.family.status.save
        changed = true
      when @umbrella
        member.status_id = @field
        member.family.status_id = @field
        member.family.status.save
        member.personnel_data.employment_status_id = @e_umbrella
        changed = true
      end  
      if changed
        member.save
        member.personnel_data.save
        member.reload
        if !(member.status && member.personnel_data.employment_status)
          puts "***** Missing/bad for #{member.name} Status=#{member.status_id}, emp_status=#{member.personnel_data.employment_status_id}"
        end 
      end  
  end

  def self.existing_statuses
    @e_umbrella = EmploymentStatus.find_by_code('umbrella').id
    @e_mk_adult = EmploymentStatus.find_by_code('mk_adult').id
    @e_mk_dependent = EmploymentStatus.find_by_code('mk_dependent').id
    @e_visitor = EmploymentStatus.find_by_code('visitor').id
    @alumni = Status.find_by_code('alumni').id
    @college = Status.find_by_code('college').id
    @alumni = Status.find_by_code('alumni').id
    @mkadult = Status.find_by_code('mkadult').id
    @mkalumni = Status.find_by_code('mkalumni').id
    @mkfield = Status.find_by_code('mkfield').id
    @field = Status.find_by_code('field').id
    @retired = Status.find_by_code('retired').id
    @umbrella = Status.find_by_code('umbrella').id
  end  

  def self.new_statuses
    @e_sim_alumni = EmploymentStatus.create(:description=>"SIM Alumni", :code=>'sim alumni').id
    @e_sim_retired = EmploymentStatus.create(:description=>"SIM Retired", :code=>'sim retired').id
    @inactive = Status.create(:description=>"Inactive", :code=>'inactive', :on_field=>'false', :active=>'false').id
  end

 
  def self.up
    new_statuses
    existing_statuses
    Member.all.each {|m| reorg(m)}
  end

  def self.down
  end
end
