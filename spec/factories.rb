#require 'spec_helper'
require 'factory_girl_rails'

#DatabaseCleaner.strategy = :truncation
#def clean
# DatabaseCleaner.clean
#end

FactoryGirl.define do
  factory :family do
    sequence(:last_name) {|n| "LastNameA_#{n}" }
    first_name "King"  
    middle_name "MiddleName"  
    short_name "Shorty"
    status_id 1
    location_id 1
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
    id 1
    code 1
    description "Description 1"
  end

  factory :country do
    id 1
    code 'AF'
    name 'Afghanistan'
    nationality 'Afghan'
  end
  
  factory :employment_status do
    id 1
    code 1
    description 'Career'
  end
  
  factory :education do
    id 1
    code 1
    description 'Educated!'
  end
  
  factory :ministry do
    id 1
    code 1
    description 'Evangelism'
  end
  
end


