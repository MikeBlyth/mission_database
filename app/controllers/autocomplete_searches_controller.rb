class AutocompleteSearchesController < ApplicationController

  def index
      @countries = Country.where("name LIKE ?", "%#{params[:term]}%").select("id, name")
p "***************" 
p @countries

  @json_resp = [  ]
  @countries.each do |c|
    @json_resp << {:label => c.name, :value => c.id}
  end
      respond_to do |format|
        format.html
        format.js { render :json => @json_resp }
        format.xml { render :xml => @countries }
      end

  end

end
