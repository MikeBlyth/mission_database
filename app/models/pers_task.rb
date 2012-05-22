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


end
