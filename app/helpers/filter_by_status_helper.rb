# This module lets Member and Family share the same filtering methods. It can be extended
# to add more filters and/or instance methods common to both models.
module FilterByStatusHelper
  # See http://railstips.org/blog/archives/2009/05/15/include-vs-extend-in-ruby/
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods

    def those_on_field
      self.joins(:status).where("on_field")
    end 

    def those_active
      self.joins(:status).where("active")
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
  
