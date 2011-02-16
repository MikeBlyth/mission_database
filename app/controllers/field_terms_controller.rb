class FieldTermsController < ApplicationController

  before_filter :authenticate #, :only => [:edit, :update]

  active_scaffold :field_term do |config|
   config.columns = [:start_date, :end_date, :ministry, :location, :employment_status,
        :est_start_date, :est_end_date]
 #  config.subform.layout = :vertical
  end

private

    def authenticate
      deny_access unless signed_in?
    end

    def correct_user
      return unless params[:id]
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

end 

