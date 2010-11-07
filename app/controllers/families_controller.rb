class FamiliesController < ApplicationController
  active_scaffold :family do |config|
#    config.show.link = false
#    list.sorting = {:code => 'ASC'}
  end

end
