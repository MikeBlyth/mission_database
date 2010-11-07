class ContactsController < ApplicationController
  active_scaffold :contact do |config|
    list.columns = [:member, :contact_type, :contact_name, :address, :phone_1, :email_1]
    config.columns[:member].actions_for_association_links = [:show]
    config.columns[:contact_type].actions_for_association_links = [:show]
    update.columns.exclude :member
    config.columns[:contact_type].form_ui = :select 
    config.columns[:contact_type].inplace_edit = true
    config.columns[:contact_name].inplace_edit = true
    config.columns[:address].inplace_edit = true
    config.columns[:phone_1].inplace_edit = true
    config.columns[:email_1].inplace_edit = true
    config.columns[:phone_public].description = "Tick box if phone is considered public"
    config.columns[:skype_public].description = "Tick box if Skype name is considered public"
    config.columns[:email_public].description = "Tick box if email is considered public"
   config.subform.layout = :vertical
 #    list.sorting = {:member.last_name => 'ASC'}
  end
end 
=begin
  
  # GET /contacts
  # GET /contacts.xml
  def index
    @contacts = Contact.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contacts }
    end
  end

  # GET /contacts/1
  # GET /contacts/1.xml
  def show
    @contact = Contact.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contact }
    end
  end

  # GET /contacts/new
  # GET /contacts/new.xml
  def new
    @contact = Contact.new
    @contact.member_id = params[:member_id] 
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contact }
    end
  end

  def dump
    
  end
  # GET /contacts/1/edit
  def edit
    @contact = Contact.find(params[:id])
  end

  # POST /contacts
  # POST /contacts.xml
  def create
    @contact = Contact.new(params[:contact])
    
    respond_to do |format|
      if @contact.save
        format.html { redirect_to(@contact, :notice => 'Contact was successfully created.') }
        format.xml  { render :xml => @contact, :status => :created, :location => @contact }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contacts/1
  # PUT /contacts/1.xml
  def update
    @contact = Contact.find(params[:id])

    respond_to do |format|
      if @contact.update_attributes(params[:contact])
        format.html { redirect_to(@contact, :notice => 'Contact was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.xml
  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy

    respond_to do |format|
      format.html { redirect_to(contacts_url) }
      format.xml  { head :ok }
    end
  end
end
=end
