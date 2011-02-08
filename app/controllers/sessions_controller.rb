class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end
  
  def create
#puts "**** Starting signin create"
#puts " Name=#{params[:session][:name]}, Password=#{params[:session][:password]}"
    user = User.authenticate(params[:session][:name],
                             params[:session][:password])

    if user.nil?
#puts "**** User is nil"
      flash.now[:error] = "Invalid name/password combination."
      @title = "Sign in"
      render 'new'
    else
      # Sign the user in and redirect to the user's show page.
#puts "**** User is being signed in"
      sign_in user
#puts "Signed_in = #{self.signed_in?}"      
      redirect_to user
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

end
