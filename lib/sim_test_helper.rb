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
    
  def create_spouse(member)
    s = Factory(:member, :spouse=>member, :last_name=> member.last_name, 
          :first_name=> "Honey", :family=>member.family, :sex=>member.other_sex, :child=>false)
    member.update_attribute(:spouse, s)
    puts "Error creating/saving spouse (sim_test_helper ~38)" unless s.valid? && member.valid?
    return s
  end
  
  def create_couple
    f = Factory(:family)
    husband = f.head
    wife = create_spouse(husband)
    return husband
  end

  # Given a record with an attribute (like status_id) that might not reflect an existing attribute record
  # since we haven't created it yet, 
  # * Do nothing if it's already created
  # * Create the record if it doesn't already exist, if the create option is true
  # * Return a valid id to insert into the record being created 
  # * Raise an exception if (record doesn't exist and is not to be created) or (unable to create the record)
  def create_associated_details(attribute, attribute_id, create=false)
    attribute_model = attribute.to_s.camelize.constantize  # e.g. Status or PersonnelData
    return attribute_id if attribute_model.find_by_id(attribute_id)   # Corresponding detail record found, return id
   # raise error if there is no corresponding detail record and one is not to be created
    raise "Unable to create needed #{attribute}=#{attribute_id},   \n" +
      "\t(specify true for create option if you want to create automatically). (create_associated_details)." unless create
    # if the attribute id is nil, e.g. :status=>nil, use first existing record if there is one 
    if attribute_id.nil?   
      return attribute_model.first.id if attribute_model.first    # Return id of existing record
    end    
    # Create new detail record if attribute value is specified or it's nil and there are no existing records
    f = Factory(attribute, :id => attribute_id || UNSPECIFIED)
    if attribute_id == UNSPECIFIED
      f.update_attribute(:description, 'Unspecified') if f.respond_to? :description
      f.update_attribute(:name, 'Unspecified') if f.respond_to? :name
    end
    raise unless f.valid? 
    return f.id
  end

  def factory_member_create(params={})
    number = rand(1000000)
    params[:last_name] ||= "Johnson #{number}"
    params[:first_name] ||= 'Gerald'
    params[:name] ||= "Johnson #{number}, Gerald"
    params[:sex] ||= 'M'
    params[:status_id] = create_associated_details(:status, params[:status_id], true)
    params[:residence_location_id] = create_associated_details(:location, params[:residence_location_id], true)
    params[:work_location_id] = create_associated_details(:location, params[:work_location_id], true)
    params[:ministry_id] = create_associated_details(:ministry, params[:ministry_id], true)
    if params[:family] 
      member = Member.create(params)
      family.head.update_attributes(params) if family.head == member
    else
      f = Family.create(:last_name=>params[:last_name],
                        :first_name=>params[:first_name],
                        :name=>params[:name],
                        :status_id=>params[:status_id],
                        :residence_location_id=>params[:residence_location_id],
                        :sim_id => rand(100000)
                        )
      member = f.head 
    end

    puts "Error updating family or family head" unless member.valid? && member.family.valid?
    create_spouse(member) if params[:spouse]
    return member
  end
  
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
