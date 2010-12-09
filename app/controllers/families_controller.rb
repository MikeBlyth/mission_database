class FamiliesController < ApplicationController
  active_scaffold :family do |config|
#    config.show.link = false
#    list.sorting = {:code => 'ASC'}
#    config.show.link.inline = false     #This sets the update link to open in its own page.
config.action_links.add "new", :label => 'Spouse', :controller=> :members, :parameters=>{:spouse=>'spouse'},
    :type => :member
config.action_links.add "new", :label => 'Add Child', :controller=> :members, :parameters=>{:child=>'child'},
    :type => :member
    list.columns = [:head, :members]  # These columns will be shown in the families list view
    update.columns = [:members]  # Only members column will be shown on the update form
    config.columns[:head].clear_link  # Do not include link to family head in the list view
    config.update.link = false  # Do not include a link to "Edit" on each line
    config.delete.link = false  # Do not include a link to "Edit" on each line
    config.show.link.page = false   # This will open the "show" view in a page, not Ajax inline
    show.columns = [:members]
    config.columns[:members].associated_limit = nil    # show all members, no limit to how many
    config.columns[:members].actions_for_association_links = [:edit]
 #   config.nested.add_link("Members", [:members])  # not working

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
