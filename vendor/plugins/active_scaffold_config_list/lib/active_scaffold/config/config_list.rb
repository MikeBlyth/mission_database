module ActiveScaffold::Config
  class ConfigList < Form
    self.crud_type = :read
    def initialize(*args)
      super
    end

    # global level configuration
    # --------------------------
    # the ActionLink for this action
    def self.link
      @@link
    end
    def self.link=(val)
      @@link = val
    end
    @@link = ActiveScaffold::DataStructures::ActionLink.new('show_config_list', :label => :config_list, :type => :collection, :security_method => :config_list_authorized?)

    # configures where the plugin itself is located. there is no instance version of this.
    cattr_accessor :plugin_directory
    @@plugin_directory = File.expand_path(__FILE__).match(%{(^.*)/lib/active_scaffold/config/config_list.rb})[1]

    # instance-level configuration
    # ----------------------------
    # the label= method already exists in the Form base class
    def label
      @label ? as_(@label) : as_(:config_list_model, :model => @core.label.singularize)
    end

    # if you do not want to show all columns as a default you may define same
    # e.g. conf.config_list.default_columns = [:name, founded_on]
    attr_accessor :default_columns
  end
end
