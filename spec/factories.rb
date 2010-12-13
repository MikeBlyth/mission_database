#require 'spec_helper'
require 'factory_girl_rails'

Factory.define :family do |f|  
  f.last_name "LastName"  
  f.first_name "King"  
  f.middle_name "MiddleName"  
  f.short_name "Shorty"
  f.status_id 1
  f.location_id 1
  f.name "LastName, FirstName"
end

Factory.define :status do |f|  
  f.code 1
  f.description "Description 1"
end

  

