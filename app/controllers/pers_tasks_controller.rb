class PersTasksController < ApplicationController
  active_scaffold :pers_task do |config|
    list.sorting = {:task => 'ASC'}
    config.label = 'Personnel Tasks'
    config.columns = [:task] + Settings.pers_task_types + [:alert]
    config.columns.each {|c| config.columns[c].inplace_edit = true }
    config.update.link = false  # Do not include a link to "Edit" on each line
#    config.delete.link = false  # Do not include a link to "Delete" on each line
    config.show.link = false  # Do not include a link to "Show" on each line
    config.delete.link.confirm = "\n"+"*" * 60 + "\nAre you sure you want to delete this task??!!\n" + "*" * 60
  end
end 
