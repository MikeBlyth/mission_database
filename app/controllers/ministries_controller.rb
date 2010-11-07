class MinistriesController < ApplicationController
  active_scaffold :ministry do |config|
    config.columns = [:code, :description]
    config.show.link = false
    config.columns[:description].inplace_edit = true
    list.sorting = {:code => 'ASC'}
  end
end 
=begin
  
  # GET /ministries
  # GET /ministries.xml
  def index
    @ministries = MinistryCode.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ministries }
    end
  end

  # GET /ministries/1
  # GET /ministries/1.xml
  def show
    @ministry = MinistryCode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ministry }
    end
  end

  # GET /ministries/new
  # GET /ministries/new.xml
  def new
    @ministry = MinistryCode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ministry }
    end
  end

  # GET /ministries/1/edit
  def edit
    @ministry = MinistryCode.find(params[:id])
  end

  # POST /ministries
  # POST /ministries.xml
  def create
    @ministry = MinistryCode.new(params[:ministry])
    
    respond_to do |format|
      if @ministry.save
        format.html { redirect_to(@ministry, :notice => 'Ministry code was successfully created.') }
        format.xml  { render :xml => @ministry, :status => :created, :location => @ministry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ministry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ministries/1
  # PUT /ministries/1.xml
  def update
    @ministry = MinistryCode.find(params[:id])

    respond_to do |format|
      if @ministry.update_attributes(params[:ministry])
        format.html { redirect_to(@ministry, :notice => 'Ministry code was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ministry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ministries/1
  # DELETE /ministries/1.xml
  def destroy
    @ministry = MinistryCode.find(params[:id])
    @ministry.destroy

    respond_to do |format|
      format.html { redirect_to(ministries_url) }
      format.xml  { head :ok }
    end
  end
end
=end