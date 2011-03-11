# This helper is to be included in a controller to user authentication

module AuthenticationHelper

  private

    def authenticate
      deny_access unless signed_in?
    end

    # Check that the user is an administrator or operating on his own user record
    def correct_user
      return unless params[:id]
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user) || current_user.admin?
    end

  public
end  
  
