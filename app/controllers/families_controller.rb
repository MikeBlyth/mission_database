class FamiliesController < ApplicationController
  active_scaffold :family do |config|
#    config.show.link = false
#    list.sorting = {:code => 'ASC'}
    config.columns[:status].form_ui = :select 
    config.columns[:location].form_ui = :select 
    config.columns[:status].inplace_edit = true
    config.columns[:members].collapsed = true
  end

end
