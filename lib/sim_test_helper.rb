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
    Factory.create(:country_unspecified)
    Factory.create(:status_unspecified)
    Factory.create(:state_unspecified)
    Factory.create(:city_unspecified)
    Factory.create(:location_unspecified)
    Factory.create(:education_unspecified)
    Factory.create(:employment_status_unspecified)
    Factory.create(:ministry_unspecified)
    Factory.create(:bloodtype_unspecified)
    @country = Factory.create(:country)
    @status = Factory.create(:status)
    @state = Factory.create(:state)
    @city = Factory.create(:city)
  puts "City=#{@city.id}, #{@city.name}"
    @location = Factory.create(:location)
    @education = Factory.create(:education)
    @employment_status = Factory.create(:employment_status)
    @ministry = Factory.create(:ministry)
    @bloodtype = Factory.create(:bloodtype)
  end

# see https://github.com/shyouhei/ruby/blob/trunk/ext/syck/lib/syck.rb#L436
    def y( object, *objects )
        objects.unshift object
        puts( if objects.length == 1
                  YAML.dump( *objects )
              else
                  YAML.dump_stream( *objects )
              end )
    end
  
#end
