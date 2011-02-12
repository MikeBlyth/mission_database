class UsersController < ApplicationController

  before_filter :authenticate #, :only => [:edit, :update]
  before_filter :correct_user #, :only => [:edit, :update]

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
    # PENDING
  end
  
private

    def authenticate
#puts "Controller #{self}.authenticate: signed_in? = #{signed_in?}"
      deny_access unless signed_in?
    end

    def correct_user
      return unless params[:id]
      @user = User.find(params[:id])
#puts "Not correct user: current=#{current_user.id}, @user=#{@user.id}" unless current_user?(@user)
      redirect_to(root_path) unless current_user?(@user)
    end

end
