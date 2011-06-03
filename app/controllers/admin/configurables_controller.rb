class Admin::ConfigurablesController < ApplicationController
  # include the engine controller actions
  include ConfigurableEngine::ConfigurablesController
  include AuthenticationHelper
  include AuthorizationHelper

load_and_authorize_resource

end
