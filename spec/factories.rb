#require 'spec_helper'
require 'factory_girl_rails'
load 'config/initializers/constants.rb'

#DatabaseCleaner.strategy = :truncation
#def clean
# DatabaseCleaner.clean
#end
#  FactoryGirl.sequence :loc do |n|
#    n
#  end



FactoryGirl.define do
  factory :bloodtype do
    id 1
    full 'AB+'
  end
  
  factory :bloodtype_unspecified, :parent => :bloodtype do
    id 999999
    full 'Unspecified'
  end

  factory :city do   
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
    member { |a| a.association :member }
    contact_type_id 1 
    email_1 'my_email@example.com'
    phone_1 '0808-888-8888'
    skype 'MySkypeName'
  end

  factory :country do
    id 1
    code 'AF'
    name 'Afghanistan'
    nationality 'Afghan'
  end
  
  factory :country_unspecified, :parent => :country do
    id UNSPECIFIED
    code '??'
    name 'Unspecified'
    nationality 'Unspecified'
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
  
  factory :family do
    sequence(:last_name) {|n| "LastNameA_#{n}" }
    first_name "King"  
    middle_name "MiddleName"  
    short_name "Shorty"
    sequence(:sim_id) {|n|  500 + n }
    name {"#{last_name}, #{first_name}"}
  end

  factory :field_term do
#    member_id 1
    member { |a| a.association :member }
    employment_status_id 5
    location_id 26
    ministry_id 6
    start_date '1 Jan 2008'
    end_date '31 Dec 2010'  
  end

  factory :field_term_future, :parent => :field_term do
    start_date ''
    end_date ''
    est_start_date '1 May 2011'
    est_end_date '30 Jan 2013'  
  end

  factory :location do
    sequence(:id) {|n| n}
    sequence(:code) {|n| 20+n}
    description 'JETS' 
    city { |a| a.association :city }
#    city_id 1
  end
  
  factory :location_unspecified, :parent => :location do
    id 999999
    code 0
    description 'Unspecified'
    city_id 999999
  end
  
  factory :member do 
#    association :family
#    family_id @family_id
    family { |a| a.association :family }
    sequence(:first_name) {|n| "Person_#{n}" }
    sex ['M','F'].shuffle[0]    # randomly pick M or F
    after_build { |user| user.inherit_from_family}
  end

  factory :member_with_details, :parent=> :member do
    middle_name 'Midname'
    short_name 'Shorty'
    birth_date '1980-01-01'
    country_id 1
    date_active '2005-01-01'
    employment_status_id 1
    ministry_id 1
    ministry_comment 'Working with orphans'
    education_id 1
    qualifications 'TESOL, qualified midwife'
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

  factory :state do
    id 1
    name 'Plateau'
  end
  
  factory :state_unspecified, :parent => :state do
    id 999999
    name 'Unspecified'
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

  factory :travel do
    member { |a| a.association :member }
    date '1 May 2011'
    return_date '15 Oct 2011'
    flight 'LH 999'
    purpose 'Home assignment'
    origin 'Abuja'
    destination 'Charlotte'
    guesthouse 'Baptist'
    baggage '2'
    total_passengers '1'
    other_travelers ''
    confirmed '14 Mar 2011'
    with_spouse false
    with_children false
  end

  factory :travel_to_field, :parent => :travel do
    date '30 Oct 2011'
    return_date ''
    flight 'BA 888'
    purpose ''
    origin 'London'
    destination 'Abuja'
    guesthouse 'Baptist'
    baggage '3'
    total_passengers '1'
    other_travelers ''
    confirmed '14 Mar 2011'
    with_spouse false
    with_children false
  end

  factory :user do 
    sequence(:name) {|n| "User_#{n}" }
    email                 "foo.bar@example.com"
    password              "foobar"
    password_confirmation "foobar"
  end  
 
end


