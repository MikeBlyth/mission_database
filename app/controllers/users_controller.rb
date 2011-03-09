class UsersController < ApplicationController

  include AuthenticationHelper

  before_filter :authenticate 
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :administrator, :only => [:new, :create, :destroy]

  def index
    @users = User.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cities }
    end
  end

  def show
    @title = 'User'
    @user = User.find(params[:id])
  end

  def new
    @title = "Sign up"
    @user = User.new
  end
 
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Successfully added user."
      redirect_to @user
    else
      @title = "Sign up"
      render 'new'
    end
  end

  def edit
  #   @user = User.find(params[:id])  # User is already found by private (authentication) method correct_user, below
    @title = "Edit user"
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
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
