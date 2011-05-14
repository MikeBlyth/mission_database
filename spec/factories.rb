#require 'spec_helper'
require 'factory_girl_rails'
load 'config/initializers/constants.rb'

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

  factory :contact_type do
    id 1
    code 1
    description 'on field'
  end  

  factory :contact_type_unspecified, :parent => :contact_type do
    id 999999
    code 999999
    description "?"
  end 
  
  factory :country do
    sequence(:id) {|n| n}
    sequence(:code) {|n| "#{n}"}
    sequence(:name) {|n| "Afghanistan #{n}" }
    nationality 'Afghan'
  end
  
  factory :country_unspecified, :parent => :country do
    id UNSPECIFIED
    code '??'
    name 'Unspecified'
    nationality 'Unspecified'
  end
  
  factory :education do
    sequence(:id) {|n| n}
    sequence(:code) {|n| n}
    sequence(:description) {|n| "Educ #{n}"}
  end

  factory :education_unspecified, :parent => :education do
    id 999999
    code 0
    description "Unspecified"
  end

  factory :employment_status do
    sequence(:id) {|n| n}
    sequence(:code) {|n| "career_#{n}"}
    sequence(:description) {|n| "Career #{n}"}
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
    employment_status { |a| a.association :employment_status }
    primary_work_location { |a| a.association :location }
    ministry { |a| a.association :ministry }
    start_date '1 Jan 2008'
    end_date '31 Dec 2010'  
  end

  factory :field_term_empty, :parent => :field_term do
    employment_status nil
    primary_work_location nil
    ministry nil
    start_date nil
    end_date nil
  end

  factory :field_term_future, :parent => :field_term do
    start_date ''
    end_date ''
    est_start_date '1 May 2011'
    est_end_date '30 Jan 2013'  
  end

  factory :health_data do
    member { |a| a.association :member }
  end    

  factory :location do
    sequence(:id) {|n| 100+n}
    sequence(:code) {|n| 20+n}
    sequence(:description) {|n| "Site #{n}"}
    city { |a| a.association :city }
#    city_id 1
  end
  
  factory :location_unspecified, :parent => :location do
    id 999999
    code 0
    description 'Unspecified'
    city_id 999999
  end
  
  factory :mail do
    from 'from@example.com'
    to   'to@example.com'
    subject 'Testing'
    date '24 November 2011'
    body 'Body of the test message'
  end

  factory :member do 
    sequence(:first_name) {|n| "Person_#{n}" }
    family { |a| a.association :family }
    sex 'M'
    after_build { |m| m.inherit_from_family}
    after_stub do |m| 
      m.last_name ||= m.family.last_name
      m.status ||= m.family.status
      m.residence_location ||= m.family.residence_location
      m.family.head = m if m.family.head.nil?
    end
  end

    factory :member_with_details, :parent=> :member do
      middle_name 'Midname'
      short_name 'Shorty'
      birth_date '1980-01-01'
      status { |a| a.association :status }
      residence_location { |a| a.association :location }
      work_location { |a| a.association :location }
      country { |a| a.association :country }
      ministry { |a| a.association :ministry } 
      ministry_comment 'Working with orphans'
    end

    factory :female, :parent=> :member do
      sex 'F'
    end

    factory :child, :parent=> :member do
      birth_date "1 Jan 2000"
      sequence(:first_name) {|n| "Child_#{n}" }
      child true
    end
  
  factory :ministry do
    sequence(:id) {|n| n}
    sequence(:code) {|n| 20+n}
    sequence(:description) {|n| "Ministry #{n}"}
  end

  factory :ministry_unspecified, :parent => :ministry do
    id 999999
    code 0
    description 'Unspecified'
  end

  factory :personnel_data do
    member { |a| a.association :member }
#    employment_status { |a| a.association :employment_status }
#    education { |a| a.association :education }
    qualifications 'TESOL, qualified midwife'
    date_active '2005-01-01'
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
    sequence(:description) {|n|  "On field #{n}" }
    on_field true
    active true
  end

  factory :status_unspecified, :parent => :status do 
    id 999999
    code 0
    description "Unspecified"
  end

  factory :status_inactive, :parent => :status do 
    description "Not active"
    on_field false
    active false
  end

  factory :status_home_assignment, :parent => :status do 
    description "Home assignment"
    on_field false
    active true
  end

  factory :travel do
    member { |a| a.association :member }
    date Date.today + 10
    return_date Date.today + 180
    flight 'LH 999'
    purpose 'Home assignment'
    origin 'Abuja'
    destination 'Charlotte'
    arrival true
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
    arrival false
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


