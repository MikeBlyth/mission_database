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
    sex 'F'
    after_build { |user| user.inherit_from_family}
  end

  factory :status do 
    code 1
    description "Description 1"
  end

end


  

