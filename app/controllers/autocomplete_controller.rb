class AutocompleteController < ApplicationController


  # AUTOCOMPLETE LOOKUP FOR COUNTRY
  def country
    @countries = Country.where("name LIKE ?", "#{params[:term]}%").select("id, name")
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
      format.js { render :json => @json_resp }
    end

  end

  # AUTOCOMPLETE LOOKUP FOR FAMILY
    def family
    @families = Member.where("name LIKE ? and family_head = true", "#{params[:term]}%").select("id, name")
    @json_resp = []
    @families.each do |c|
      @json_resp << c.name
    end

    respond_to do |format|
      format.js { render :json => @json_resp }
    end
  end

  # AUTOCOMPLETE LOOKUP FOR SPOUSE
  def spouse
    member = Member.find(params[:member])
    if member.sex.downcase == 'f'
      target_sex = 'm'
    else
      target_sex = 'f'
    end
    @possible = Member.where("last_name = ?", member.last_name).where("sex = ?", target_sex).select("id, name")
    @json_resp = []
    @possible.each do |c|
      @json_resp << c.name
    end
    @json_resp << '--Other--'
    respond_to do |format|
      format.js { render :json => @json_resp }
    end
  end


end
