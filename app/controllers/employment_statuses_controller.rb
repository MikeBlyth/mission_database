class EmploymentStatusesController < ApplicationController
  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  
  active_scaffold :employment_status do |config|
    config.columns = [:code, :description]
    config.show.link = false
    config.columns[:description].inplace_edit = true
    list.sorting = {:code => 'ASC'}
  end
end 

  # GET /employment_statuses
  # GET /employment_statuses.xml
=begin
  
  def index
    @employment_statuses = EmploymentStatusCode.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @employment_statuses }
    end
  end

  # GET /employment_statuses/1
  # GET /employment_statuses/1.xml
  def show
    @employment_status = EmploymentStatusCode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @employment_status }
    end
  end

  # GET /employment_statuses/new
  # GET /employment_statuses/new.xml
  def new
    @employment_status = EmploymentStatusCode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @employment_status }
    end
  end

  # GET /employment_statuses/1/edit
  def edit
    @employment_status = EmploymentStatusCode.find(params[:id])
  end

  # POST /employment_statuses
  # POST /employment_statuses.xml
  def create
    @employment_status = EmploymentStatusCode.new(params[:employment_status])

    respond_to do |format|
      if @employment_status.save
        format.html { redirect_to(@employment_status, :notice => 'Employment status code was successfully created.') }
        format.xml  { render :xml => @employment_status, :status => :created, :location => @employment_status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @employment_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /employment_statuses/1
  # PUT /employment_statuses/1.xml
  def update
    @employment_status = EmploymentStatusCode.find(params[:id])

    respond_to do |format|
      if @employment_status.update_attributes(params[:employment_status])
        format.html { redirect_to(@employment_status, :notice => 'Employment status code was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @employment_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /employment_statuses/1
  # DELETE /employment_statuses/1.xml
  def destroy
    @employment_status = EmploymentStatusCode.find(params[:id])
    @employment_status.destroy

    respond_to do |format|
      format.html { redirect_to(employment_statuses_url) }
      format.xml  { head :ok }
    end
  end
end
=end
