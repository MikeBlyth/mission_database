require 'member.rb'

class Member
  def add_details
    self.update_attributes(:middle_name => 'Midname',
            :short_name => 'Shorty',
            :birth_date => '1980-01-01',
            :country_id => 1,
            :ministry_id => 1,
            :ministry_comment => 'Working with orphans',
    self.personnel_data.update_attributes(
            :date_active => '2005-01-01',
            :employment_status_id => 1,
            :education_id => 1,
            :qualifications => 'TESOL, qualified midwife')
  end
end



