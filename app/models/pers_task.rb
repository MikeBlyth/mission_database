# == Schema Information
# Schema version: 20120522135023
#
# Table name: pers_tasks
#
#  id             :integer         not null, primary key
#  task           :string(255)
#  pipeline       :boolean
#  orientation    :boolean
#  start_of_term  :boolean
#  end_of_term    :boolean
#  end_of_service :boolean
#  alert          :boolean
#  created_at     :datetime
#  updated_at     :datetime
#

class PersTask < ActiveRecord::Base
  include ModelHelper
  validates_presence_of :task

  def to_s
    self.task
  end
  
  def description
    self.task
  end

  # For a type (like :pipeline or :orientation), return the array of task ids that
  # are defined for that type
  def self.task_ids(type)
    self.all.map {|t| t.id if t.send(type)}.compact
  end
  
  def self.tasks_hash
    self.task_types.map {|typ| {:type=>typ, :ids=>self.task_ids(typ)} }
  end
  
  # An array of all the types of task (like :pipeline ...), sorted according to the 
  # order they should be displayed. Currently this is defined in the 
  # config/settings/site_settings.yml file
  def self.task_types
    Settings.pers_task_types
#    [:pipeline, :orientation]
  end
  
end
