# This helper is to be included in a controller to user authentication, i.e. to block access to that controller's methods 
# except when the is a properly-signed-in user.

module AuthenticationHelper
#  before_filter :authenticate

  private

      def authenticate
        deny_access unless signed_in?
      end

    def administrator
      unless current_user.admin?
        flash[:error] = "Only administrators can do that"
        redirect_to(root_path) 
      end  
    end  

    # Check that the user is an administrator or operating on his own user record
    def correct_user
      return unless params[:id]
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user) || current_user.admin?
    end

  public
end  
  
