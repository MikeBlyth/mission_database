# This module lets Member and Family share the same filtering methods. It can be extended
# to add more filters and/or instance methods common to both models.
module FilterByStatusHelper
  
  def self.included(base)
    # See http://railstips.org/blog/archives/2009/05/15/include-vs-extend-in-ruby/ for how the self.included(base) works
    base.extend(ClassMethods)
  end
  
  module ClassMethods

    def those_on_field
      self.joins(:status).where("on_field")
    end 

    def those_active_sim
      self.those_active.joins(:personnel_data).where("employment_status_id in (?)", EmploymentStatus.org_statuses)
    end 

    def those_active
      self.joins(:status).where("active").readonly(false) 
    end 

    def those_active_adults
      self.joins(:status).where("active and not child").readonly(false) 
    end 

    def those_on_field_or_active
      self.joins(:status).where("active or on_field")
    end 

    # This is a little different because it filters based on status.code
    def those_with_status(*targets)
      self.joins(:status).where("code in (?)", targets)
    end 

  end # ClassMethods module

  # Instance methods go here

end  
  
