class UsersController < ApplicationController

  include AuthenticationHelper
  include AuthorizationHelper

load_and_authorize_resource
  
#  before_filter :authenticate 

  def index
    unless can? :create, User
      redirect_to root_path
      return
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cities }
    end
  end

  def show
    @title = 'User'
#    @user = User.find(params[:id])
  end

  def new
    @title = "New user"
#    @user = User.new
  end
 
  def create
#    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Successfully added user."
      redirect_to @user
    else
      @title = "Sign up"
      render 'new'
    end
  end

  def administrator
    self.admin?
  end

  def edit
    correct_user # from authentication_helper; redirects to root if user is not the same as the record being operated on
    @user = User.find(params[:id])
    @title = "Edit user"
  end

  def edit_roles
    @user = User.find(params[:id])
    @title = "Edit roles"
  end    

  def update
    return unless correct_user # from authentication_helper; redirects to root if user is not the same as the record being operated on
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  # Use a separate method for updating roles since only admin is allowed to do this
  def update_roles 
    @user = User.find(params[:id])
    params[:user].each do |role, value|
      if AuthorizationHelper::ROLES[role]   # This is a valid role?
        @user.update_attribute(role, value)
      end
    end
    flash[:success] = "Profile updated."
    redirect_to @user
  end  
  
  # TODO
  def destroy
    user = User.find(params[:id])
    if user.destroy
      flash[:success] = "User deleted."
    else
      flash[:errors] = user.errors[:delete][0]
    end    
    redirect_to users_path
  end
  
end
