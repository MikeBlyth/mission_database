class StatusesController < ApplicationController
  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  
  active_scaffold :status do |config|
    config.columns = [:code, :description, :active, :on_field]
    config.show.link = false
    config.columns[:description].inplace_edit = true
    config.columns[:active].inplace_edit = true
    config.columns[:on_field].inplace_edit = true
    config.columns[:on_field].description = "People with this status are on the field?"
    config.columns[:active].description = "People with this status are active?"
    list.sorting = {:code => 'ASC'}
  end
end 

=begin
  # GET /statuses
  # GET /statuses.xml
  def index
    @statuses = StatusCode.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @statuses }
    end
  end

  # GET /statuses/1
  # GET /statuses/1.xml
  def show
    @status = StatusCode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @status }
    end
  end

  # GET /statuses/new
  # GET /statuses/new.xml
  def new
    @status = StatusCode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @status }
    end
  end

  # GET /statuses/1/edit
  def edit
    @status = StatusCode.find(params[:id])
  end

  # POST /statuses
  # POST /statuses.xml
  def create
    @status = StatusCode.new(params[:status])

    respond_to do |format|
      if @status.save
        format.html { redirect_to(@status, :notice => 'Status code was successfully created.') }
        format.xml  { render :xml => @status, :status => :created, :location => @status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /statuses/1
  # PUT /statuses/1.xml
  def update
    @status = StatusCode.find(params[:id])

    respond_to do |format|
      if @status.update_attributes(params[:status])
        format.html { redirect_to(@status, :notice => 'Status code was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /statuses/1
  # DELETE /statuses/1.xml
  def destroy
    @status = StatusCode.find(params[:id])
    @status.destroy

    respond_to do |format|
      format.html { redirect_to(statuses_url) }
      format.xml  { head :ok }
    end
  end
end
=end
