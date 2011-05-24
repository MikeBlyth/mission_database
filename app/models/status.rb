# == Schema Information
# Schema version: 20110524121604
#
# Table name: statuses
#
#  id              :integer         not null, primary key
#  description     :string(255)
#  code            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  active          :boolean
#  on_field        :boolean
#  pipeline        :boolean
#  leave           :boolean
#  home_assignment :boolean
#

class Status < ActiveRecord::Base
  include ModelHelper
  before_destroy :check_for_linked_records
  has_many :members
  has_many :families
  validates_uniqueness_of :code, :description
  validates_presence_of :code, :description

  # Class method Status.field_statuses and Status.active_statuses
  # Return array of status_ids for statuses of given category
  #   (i.e. if a member or family has this status, the member or family is considered 
  #   to be on the field)
  # Categories are represented by columns in the statuses table. 
  # The 'category' argument can be string or label if it's a single column.
  # AND/OR expressions can be used if 'category' is a string, since it is passed directly
  # to the 'where' expression. So you can say
  # Status.statuses_by_category('on_field or active')
  def self.statuses_by_category(category)
    selected = self.where(category.to_s)
    ids = selected.map {|x| x.id}
    return ids
  end
    
  # Convenience methods
    def self.field_statuses
      self.statuses_by_category('on_field')
    end
    
    def self.home_assignment_statuses
      self.statuses_by_category('home_assignment')
    end
    
    def self.leave_statuses
      self.statuses_by_category('leave')
    end
    
    def self.pipeline_statuses
      self.statuses_by_category('pipeline')
    end
    
    def self.active_statuses
      self.statuses_by_category('active')
    end

    def self.other_statuses
      self.all.map {|status| status.id} - field_statuses-home_assignment_statuses-
                                        leave_statuses - pipeline_statuses -
                                        active_statuses
    end

  def to_label
    self.to_s
  end
  
  def to_s
    self.description
  end

end
