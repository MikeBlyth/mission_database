require Rails.root.join('spec/factories')
#require 'application_helper'

module SimTestHelper
#  include ApplicationHelper
  def create_one_unspecified_code(type, params={})
    type = type.to_s.camelcase.constantize if type.class == Symbol
    unless type.find_by_id(UNSPECIFIED)
      s = type.new(params)
      s.description ||= "Unspecified" if s.respond_to? :description
      s.full ||= "Unspecified" if s.respond_to? :full
      s.code ||= "999999" if s.respond_to? :code
      s.country = "Unspecified" if s.respond_to? :country and !params[:country]
      s.name ||= "Unspecified" if s.respond_to? :name
      s.id = UNSPECIFIED
      s.save
      puts "Errors saving #{type} unspecified: #{s.errors}" if s.errors.length > 0
    end
#puts "create_one_unspec... #{type} #{s}"
  return s
  end    
    
  def create_unspecified_codes
    create_one_unspecified_code(Status)
    create_one_unspecified_code(Ministry)
    create_one_unspecified_code(Country)
    create_one_unspecified_code(City)
    create_one_unspecified_code(Location)
    create_one_unspecified_code(Education)
    create_one_unspecified_code(EmploymentStatus)
    create_one_unspecified_code(Bloodtype)
    create_one_unspecified_code(ContactType)
  end  
    
  def factory_member_create(params={})
    number = rand(1000000)
    params[:last_name] ||= "Johnson #{number}"
    params[:first_name] ||= 'Gerald'
    params[:name] ||= 'Johnson #{number}, Gerald'
    params[:sex] ||= 'M'
    params[:status_id] ||= UNSPECIFIED
    params[:residence_location_id] ||= UNSPECIFIED
    params[:work_location_id] ||= UNSPECIFIED
    params[:ministry_id] ||= UNSPECIFIED
    family = params[:family] ||
      Family.create(:last_name=>params[:last_name],
                        :first_name=>params[:first_name],
                        :name=>params[:name],
                        :status_id=>params[:status_id],
                        :residence_location_id=>params[:residence_location_id],
                        :sim_id => rand(100000)
                        )
    if params[:family]
      return Member.create(params)
    else
#puts "Family created, #{family.attributes}, errors=#{family.errors}, head=#{family.head_id}"
      family.head.update_attributes(params)
      puts "Error updating family head" unless family.head.valid?
      return family.head
    end
  end    

  def add_details(member)
    location = Location.last
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
    member.personnel_data.update_attributes(
            :date_active => '2005-01-01',
            :employment_status => EmploymentStatus.first,
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
    locations_hash.each do |location| 
      Factory.create(:location, :id=>location[:id], :city_id=>location[:city_id],
              :description=>location[:description])
    end
    Factory.create(:location_unspecified, :city_id => 999999)
    @locations = Location.all
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
