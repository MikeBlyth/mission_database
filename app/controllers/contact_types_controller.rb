class ContactTypesController < ApplicationController
  active_scaffold :contact_type do |config|
    config.columns = [:code, :description]
    config.show.link = false
    update.columns= create.columns = [:code, :description]
    config.columns[:description].inplace_edit = true
    list.sorting = {:code => 'ASC'}
  end
end 
=begin
  
  # GET /contact_types.xml
  def index
    @contact_types = ContactType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contact_types }
    end
  end

  # GET /contact_types/1
  # GET /contact_types/1.xml
  def show
    @contact_type = ContactType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contact_type }
    end
  end

  # GET /contact_types/new
  # GET /contact_types/new.xml
  def new
    @contact_type = ContactType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contact_type }
    end
  end

  # GET /contact_types/1/edit
  def edit
    @contact_type = ContactType.find(params[:id])
  end

  # POST /contact_types
  # POST /contact_types.xml
  def create
    @contact_type = ContactType.new(params[:contact_type])

    respond_to do |format|
      if @contact_type.save
        format.html { redirect_to(@contact_type, :notice => 'Contact type was successfully created.') }
        format.xml  { render :xml => @contact_type, :status => :created, :location => @contact_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contact_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contact_types/1
  # PUT /contact_types/1.xml
  def update
    @contact_type = ContactType.find(params[:id])

    respond_to do |format|
      if @contact_type.update_attributes(params[:contact_type])
        format.html { redirect_to(@contact_type, :notice => 'Contact type was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contact_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contact_types/1
  # DELETE /contact_types/1.xml
  def destroy
    @contact_type = ContactType.find(params[:id])
    @contact_type.destroy

    respond_to do |format|
      format.html { redirect_to(contact_types_url) }
      format.xml  { head :ok }
    end
  end
end

=end
