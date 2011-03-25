require Rails.root.join('spec/factories')
#require 'application_helper'

module SimTestHelper
#  include ApplicationHelper
  def add_details(member)
    location = Location.last
#puts "\nadd details, Country.all=#{Country.all}, first=#{Country.first}\n"
    member.update_attributes(:middle_name => 'Midname',
            :short_name => 'Shorty',
            :sex => 'M',
            :birth_date => '1980-01-01',
            :country => Country.first,
            :status => Status.first,
            :residence_location => Location.first,
            :ministry => Ministry.first,
            :ministry_comment => 'Working with orphans'
            )
#puts "**** Now member.country=#{member.country}, valid=#{member.valid?}, errors=#{member.errors}"
#member.reload
#puts "**** after reload in add_details member.country=#{member.country}"

    member.personnel_data.update_attributes(
            :date_active => '2005-01-01',
            :employment_status=> EmploymentStatus.first,
            :education => Education.first,
            :qualifications => 'TESOL, qualified midwife')
  end

  def test_init
    SimTestHelper::seed_tables
    @f = Factory.create(:family)
    @h = @f.head
    @contact = Factory.create(:contact, :member => @h)
    @travel = Factory.create(:travel, :member => @h)
    @field_term = Factory.create(:field_term, :member => @h)
  end
 
  def seed_tables
    @country = Country.first || Factory.create(:country) 
    @status = Factory.create(:status)
    @state = Factory.create(:state)
    @city = Factory.create(:city)
    @location = Factory.create(:location)
    @education = Factory.create(:education)
    @employment_status = Factory.create(:employment_status)
    @ministry = Factory.create(:ministry)
    @bloodtype = Factory.create(:bloodtype)
    Factory.create(:country_unspecified) unless Country.exists?(UNSPECIFIED)
    Factory.create(:status_unspecified)
    Factory.create(:state_unspecified)
    Factory.create(:city_unspecified)
    Factory.create(:location_unspecified)
    Factory.create(:education_unspecified)
    Factory.create(:employment_status_unspecified)
    Factory.create(:ministry_unspecified)
    Factory.create(:bloodtype_unspecified)
  end

# This is just a convenient way of defining a few locations to be created 
  def locations_hash
   [ 
                  {:city=>'Jos', :city_id => 2, :description=>'Evangel', :id=>1},
                  {:city=>'Jos', :city_id => 2, :description=>'JETS', :id=>3},
                  {:city=>'Jos', :city_id => 2, :description=>'ECWA', :id=>2},
                  {:city=>'Miango', :city_id => 4, :description=>'MRH', :id=>4},
                  {:city=>'Miango', :city_id => 2, :description=>'KA', :id=>5},
                  {:city=>'Miango', :city_id => 2, :description=>'Miango Dental Clinic', :id=>6},
                  {:city=>'Kano', :city_id => 3, :description=>'Tofa Bible School', :id=>7},
                  {:city=>'Kano', :city_id => 3, :description=>'Kano Eye Hospital', :id=>8},
                  {:city=>'Abuja', :city_id => 5, :description=>'Abuja Guest House', :id=>9}
    ]
  end
  
  def setup_cities
    Factory.create(:city, :name => 'Jos', :id=>2)
    Factory.create(:city, :name => 'Kano', :id=>3)
    Factory.create(:city, :name => 'Miango', :id=>4)
    Factory.create(:city, :name => 'Abuja', :id=>5)
    Factory.create(:city_unspecified)
  end

  def setup_locations
    if City.find_by_name('Miango').nil?
      City.delete_all
      setup_cities
    end  
    locations_hash.each do |location| 
      Factory.create(:location, :id=>location[:id], :city_id=>location[:city_id],
              :description=>location[:description])
    end
    Factory.create(:location_unspecified, :city_id => 999999)
    @locations = Location.all
  end

  # Given parent (like :status) and child (like :member), check that the parent record
  # cannot be deleted if there are still children linked to it. For example, we should
  # not be able to delete a status record if there are still members who have that status.
  # Example: test_check_before_destroy(:status, :member)
  def test_check_before_destroy(parent, child)
    @parent = Factory(parent)
    @other_parent = Factory((parent.to_s+'_unspecified').to_sym)
    @child = Factory(child, parent=>@other_parent)
    lambda do
      @parent.destroy
    end.should change(parent.to_s.camelcase.constantize, :count).by(-1)
  
    @child = Factory(child)
    @child.update_attribute(parent, @parent)
    lambda do
      @parent.destroy
    end.should_not change(parent.to_s.camelcase.constantize, :count)
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
  
end #Module
