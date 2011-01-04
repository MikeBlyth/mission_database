ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'email_validator'
require 'sim_test_helper'
#require 'email_veracity'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def assert_valid(object, message='assert valid failed')
    assert(object.valid?,message)
  end

  def assert_invalid(object, message='assert invalid')
    assert(!object.valid?,message)
  end
  alias assert_not_valid assert_invalid
  
  # This doesn't work right yet; should allow for validation by passing just the class
  # without having to make an instance of it first.
  def createit(xclass,params,field)
    cloned = xclass.new(params)
    cloned.instance_eval do
      @errors = nil
    end
    cloned.member_id = nil
    assert(cloned.valid?, "Creatit not valid at start")
    cloned.send("#{field}=", 9995)
    cloned.member_id = nil
    assert(!cloned.valid?, "Createit not valid when nil")    
  end

  def assert_presence_required(object, field)
  # Test that the initial object is valid
    cloned = object.clone
    # This is needed to "clear" the errors in case object has already been validated
    cloned.instance_eval {@errors = nil}
    assert(object.valid?,"Object already invalid on call to assert_presence_required")
    # Test that it becomes invalid by removing the field
    cloned.send("#{field}=", nil)
    assert(!cloned.valid?,"Should reject object without #{field}")
    assert(cloned.errors[field], "Expected an error message on validation for #{field}")
  end

  def assert_parent_required(object, field, test_value)
    cloned = object.clone
    # This is needed to "clear" the errors in case object has already been validated
    cloned.instance_eval do
      @errors = nil
    end
    # Insert bad value (one not representing a matching parent id) and test
    cloned.send("#{field}=", test_value)
    assert(!cloned.valid?, "Should reject #{field} w/o corresponding member\n#{cloned.attributes.to_s}")
  end

  # Several models have code and description. To validate them, need to be sure that 
  # both attributes are required and that uniqueness is required.
  def assert_code_and_desc_ok(object)
    cloned = object.clone
    assert_presence_required(object,:code)
    assert_presence_required(object,:description)
    assert object.save,"Failed to save object first time in uniqueness test; pass unique record first"
    assert !cloned.save,"Saved object twice while testing for uniqueness of :code and :description"
    assert(cloned.errors[:code].to_s =~ /taken/,   "Missing or wrong error message for duplicate code" )
    assert(cloned.errors[:description].to_s =~ /taken/,   "Missing or wrong error message for duplicate description") 
  end

end
