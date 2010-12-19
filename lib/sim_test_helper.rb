require Rails.root.join('spec/factories')
require 'member'

class Member
  def add_details
    self.update_attributes(:middle_name => 'Midname',
            :short_name => 'Shorty',
            :birth_date => '1980-01-01',
            :country_id => 1,
            :date_active => '2005-01-01',
            :employment_status_id => 1,
            :ministry_id => 1,
            :ministry_comment => 'Working with orphans',
            :education_id => 1,
            :qualifications => 'TESOL, qualified midwife')
  end
end

#Module SIM_Test_Helper
  
  def seed_tables
    @country = Factory.create(:country)
    @state = Factory.create(:state)
    @city = Factory.create(:city)
    @location = Factory.create(:location)
    @education = Factory.create(:education)
    @employment_status = Factory.create(:employment_status)
    @ministry = Factory.create(:ministry)
    @bloodtype = Factory.create(:bloodtype)
  end
  
#end
