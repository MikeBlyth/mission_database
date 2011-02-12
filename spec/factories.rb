#require 'spec_helper'
require 'factory_girl_rails'

#DatabaseCleaner.strategy = :truncation
#def clean
# DatabaseCleaner.clean
#end
#  FactoryGirl.sequence :loc do |n|
#    n
#  end



FactoryGirl.define do
  factory :family do
    sequence(:last_name) {|n| "LastNameA_#{n}" }
    first_name "King"  
    middle_name "MiddleName"  
    short_name "Shorty"
    sequence(:sim_id) {|n|  500 + n }
    name {"#{last_name}, #{first_name}"}
  end

  factory :member do 
  #  association :family
    family @family
    sequence(:first_name) {|n| "Person_#{n}" }
    sex ['M','F'].shuffle[0]    # randomly pick M or F
    after_build { |user| user.inherit_from_family}
  end

  factory :member_with_details, :parent=> :member do
    middle_name 'Midname'
    short_name 'Shorty'
    birthdate '1980-01-01'
    country_id 1
    date_active '2005-01-01'
    employment_status_id 1
    ministry_id 1
    ministry_comment 'Working with orphans'
    education_id 1
    qualifications 'TESOL, qualified midwife'
  end
  
  factory :status do 
    sequence(:id) {|n| n}
    sequence(:code) {|n| 100+n}
    sequence(:description) {|n|  "On field_#{n}" }
  end

  factory :status_unspecified, :parent => :status do 
    id 999999
    code 0
    description "Unspecified"
  end

  factory :country do
    id 1
    code 'AF'
    name 'Afghanistan'
    nationality 'Afghan'
  end
  
  factory :country_unspecified, :parent => :country do
    id 999999
    code '??'
    name 'Unspecified'
    nationality 'Unspecified'
  end
  
  factory :employment_status do
    id 1
    code 1
    description 'Career'
  end
  
  factory :employment_status_unspecified, :parent => :employment_status do
    id 999999
    code 0
    description "Unspecified"
  end
  
  factory :education do
    id 1
    code 1
    description 'Educated!'
  end

  factory :education_unspecified, :parent => :education do
    id 999999
    code 0
    description "Unspecified"
  end

  factory :state do
    id 1
    name 'Plateau'
  end
  
  factory :state_unspecified, :parent => :state do
    id 999999
    name 'Unspecified'
  end
  
  factory :city do   
    id 1
    name 'Jos'
    country 'ng'
    state 'Plateau'
  end

  factory :city_unspecified, :parent => :city do   
    id 999999
    name 'Unspecified'
    country '??'
    state ''
  end
  
  factory :contact do
    member_id 1
    contact_type_id 1 
    email_1 'my_email@example.com'
    phone_1 '0808-888-8888'
    skype 'MySkypeName'
  end

  factory :field_term do
    member_id 1
    status_id 3
    location_id 26
    ministry_id 6
    start_date '1 Jan 2008'
    end_date '31 Dec 2010'  
  end

  factory :location do
    sequence(:id) {|n| n}
    sequence(:code) {|n| 20+n}
    description 'JETS' 
    city_id 1
  end
  
  factory :location_unspecified, :parent => :location do
    id 999999
    code 0
    description 'Unspecified'
    city_id 999999
  end
  
  factory :ministry do
    id 1
    code 1
    description 'Evangelism'
  end

  factory :ministry_unspecified, :parent => :ministry do
    id 999999
    code 0
    description 'Unspecified'
  end

  factory :bloodtype do
    id 1
    full 'AB+'
  end
  
  factory :bloodtype_unspecified, :parent => :bloodtype do
    id 999999
    full 'Unspecified'
  end

  factory :user do 
    name                  "Foo Bar"
    email                 "foo.bar@example.com"
    password              "foobar"
    password_confirmation "foobar"
  end  
 
end


