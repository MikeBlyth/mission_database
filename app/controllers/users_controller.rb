class UsersController < ApplicationController

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

end
