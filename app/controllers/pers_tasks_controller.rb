class PersTasksController < ApplicationController
  active_scaffold :pers_task do |config|
    list.sorting = {:task => 'ASC'}
    config.label = 'Personnel Tasks'
    config.columns = [:task, :pipeline, :orientation, :start_of_term, :end_of_term, :end_of_service, :alert]
    config.columns[:task].inplace_edit = true
    config.columns[:pipeline].inplace_edit = true
    config.columns[:orientation].inplace_edit = true
    config.columns[:start_of_term].inplace_edit = true
    config.columns[:end_of_term].inplace_edit = true
    config.columns[:end_of_service].inplace_edit = true
    config.columns[:alert].inplace_edit = true
    config.update.link = false  # Do not include a link to "Edit" on each line
#    config.delete.link = false  # Do not include a link to "Delete" on each line
    config.show.link = false  # Do not include a link to "Show" on each line
    config.delete.link.confirm = "\n"+"*" * 60 + "\nAre you sure you want to delete this task??!!\n" + "*" * 60
  end
end 
