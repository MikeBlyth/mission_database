class AutocompleteSearchesController < ApplicationController

  def index
    @countries = Country.where("name LIKE ?", "%#{params[:term]}%").select("id, name")
    @json_resp = []
    @countries.each do |c|
      # This method shows the user the labels (country names in this case), but then
      #   inserts the value (the country id in this case) into the input box
      #    @json_resp << {:label => c.name, :value => c.id}
      #
      # This method simply puts the country name into the input box. This means that the 
      #   controller must look it up before saving the record.
      @json_resp << c.name
    end

    respond_to do |format|
#      format.html
      format.js { render :json => @json_resp }
#      format.xml { render :xml => @countries }
    end

  end

end
