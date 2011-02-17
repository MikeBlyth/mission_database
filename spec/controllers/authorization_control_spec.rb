require 'spec_helper'
require 'auth_spec_helper'

include AuthSpecHelper

# Check that access to controller is blocked when user is not logged in (use deny_access method defined in spec_helper)
# "authentication before controller access"

def generic(controller, objectsym)
  describe controller do
    it "should limit access to signed-in users" do
      object = Factory(objectsym)
      check_authentication(object)
    end
  end
end      
  
controllers = [
                [BloodtypesController, :bloodtype],
                [CitiesController, :city],
                [ContactsController, :contact],
                [CountriesController, :country],
                [EducationsController, :education],
                [EmploymentStatusesController, :employment_status],
                [FamiliesController, :family],
                [FieldTermsController, :field_term],
                [LocationsController, :location],
                [MembersController, :member],
                [StatesController, :state],
                [StatusesController, :status],
                [TravelsController, :travel]
              ]  
  
controllers.each { |controller, obj_sym| generic(controller, obj_sym) }



