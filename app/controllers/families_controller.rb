class FamiliesController < ApplicationController
  active_scaffold :family do |config|
#    config.show.link = false
#    list.sorting = {:code => 'ASC'}
#    config.show.link.inline = false     #This sets the update link to open in its own page.

    config.columns[:status].form_ui = :select 
    config.columns[:location].form_ui = :select 
    config.columns[:status].inplace_edit = true
    config.columns[:members].collapsed = true
  end

#  def show
#    @family = Family.find(params[:id])
#puts "@family = #{@family.to_label}"
#    respond_to do |format|
#puts "************ 1" 
#     format.html # show.html.erb

#      format.xml  { render :xml => @family }
#    end
#  end


end
