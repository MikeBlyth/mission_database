  class Settings < Settingslogic
    source "#{Rails.root}/config/application_settings.yml"
    namespace Rails.env
  end

