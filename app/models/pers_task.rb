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

  attr_accessor :finished

  def to_s
    self.task
  end
  
  def description
    self.task
  end

  # An array of all the types of task (like :pipeline ...), sorted according to the 
  # order they should be displayed. Currently this is defined in the 
  # config/settings/site_settings.yml file
  def self.task_types
    Settings.pers_task_types
  end

  # Update the finished flag from the standard param hash
  def update_finished(params)
    self.finished = (params["task_#{self.id}"] == '1')
  end

  def self.tasks_w_finished_marked(finished_string)
    # Mark the tasks that are finished, creating a new array of tasks in the process
    finished_marked = self.all.map do |task| 
      task.finished = (finished_string =~ Regexp.new(task.id.to_s))
      task
    end
    hash = self.task_types.map do |typ| 
      task = {:type=>typ}
      task[:tasks] = finished_marked.map {|task| task if task.send(typ)}.compact  # array of tasks with type==typ
      task
    end
    return hash
  end
  
  # For a type (like :pipeline or :orientation), return the array of task ids that
  # are defined for that type
  def self.task_ids(type)
    self.all.map {|task| task.id if task.send(type)}.compact
  end
  
  # For a type (like :pipeline or :orientation), return the array of tasks
  # are defined for that type
  def self.tasks_with_type(type)
    self.all.map {|task| task if task.send(type)}.compact
  end
  
#  # Array of hashes, one for each type, like
#  #   [{:type=>:pipeline, :tasks=>[array of tasks]}, ...]
#  def self.tasks_hash
#    self.task_types.map {|typ| {:type=>typ, :ids=>self.tasks_with_typ(typ)} }
#  end
  
end

#class PersTaskArray < Array


#  def initialize(finished_string)
#    all_tasks = pers_tasks_w_finished_marked(finished_string)
#    hash = PersTask.task_types.map do |typ| 
#      task = {:type=>typ}
#      task[:tasks] = all_tasks.map {|task| task if task.send(type)}.compact  # array of tasks with type==typ
#      {:type=>typ, :tasks=>self.tasks_with_type(typ)} }

#  # For a type (like :pipeline or :orientation), return the array of tasks
#  # are defined for that type
#  def tasks_with_type(type)
#    self.map {|task| task if task.send(type)}.compact
#  end    
#  
#  # Array of hashes, one for each type, like
#  #   [{:type=>:pipeline, :tasks=>[array of tasks]}, ...]
#  def tasks_hash
#    PersTask.task_types.map {|typ| {:type=>typ, :tasks=>self.tasks_with_type(typ)} }
#  end    
#  
##  # List in comma-delimited string form the finished tasks in the array
##  def finished_tasks_string
##    finished_ids = self.map {|task| task.id.to_s if task.finished}.compact.join(',')
##  end
#  

#end
