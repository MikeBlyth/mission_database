# This helper is to be included in a controller to user authentication

module AuthenticationHelper

  private

    def authenticate
      deny_access unless signed_in?
    end

    # Check that the user is an administrator or operating on his own user record
    def correct_user
#puts "authentication_helper correct_user: params=#{params}"
      return unless params[:id]
      @user = User.find(params[:id])
#puts ">> @user=#{@user.id}, current_user?(@user)=#{current_user?(@user)}"
      if current_user?(@user) || current_user.admin?
        return true
      else 
        redirect_to(root_path) 
        return false   
      end 
    end

  public
end  
  
