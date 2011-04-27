module ActiveScaffold::Actions
  module ConfigList
    
    def self.included(base)
      base.before_filter :store_config_list_params_into_session, :only => [:index]
      base.helper_method :config_list_params

      as_config_list_plugin_path = File.join(ActiveScaffold::Config::ConfigList.plugin_directory, 'frontends', 'default' , 'views')
      
      base.add_active_scaffold_path as_config_list_plugin_path
    end

    def show_config_list
      respond_to do |type|
        type.html do
          render(:action => 'show_config_list_form', :layout => true)
        end
        type.js do
          render(:partial => 'show_config_list_form', :layout => false)
        end
      end
    end
    
    protected

    def store_config_list_params_into_session
      if params[:config_list]
        active_scaffold_session_storage[:config_list] = params.delete :config_list
        case active_scaffold_session_storage[:config_list]
        when String
          active_scaffold_session_storage[:config_list] = nil
        when Array
          active_scaffold_session_storage[:config_list].collect!{|col_name| col_name.to_sym}
        end
      end
    end

    def config_list_params
      active_scaffold_session_storage[:config_list] || active_scaffold_config.config_list.default_columns
    end

    def do_config_list
      active_scaffold_config.list.columns.column_order.clear
      if !config_list_params.nil? && config_list_params.is_a?(Array)
         active_scaffold_config.list.columns.column_order.concat(config_list_params)
      end
    end

    def list_columns
      columns = super
      if !config_list_params.nil? && config_list_params.is_a?(Array)
        config_list = config_list_params
        columns.select{|column| config_list.include? column.name}.sort{|x,y| config_list.index(x.name) <=> config_list.index(y.name)}
      else
        columns
      end
    end

    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def config_list_authorized?
      authorized_for?(:action => :read)
    end
  end
end
