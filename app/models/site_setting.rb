# == Schema Information
# Schema version: 20110604193420
#
# Table name: site_settings
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  value      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class SiteSetting < ActiveRecord::Base
# Taken from Configurable_Engine by Paulca
# https://github.com/paulca/configurable_engine
  
  def self.defaults
    HashWithIndifferentAccess.new(
      YAML.load_file(
        Rails.root.join('config', 'site_settings.yml')
      )
    )
  end
  
  def self.keys
    self.defaults.collect { |k,v| k.to_s }.sort
  end
  
  def self.[](key)
    unless self.defaults[key]
      raise "Site settings key '#{key}' not found in config/site_settings.yml"
    end
    value = find_by_name(key).try(:value) || (self.defaults[key])[:default]
    case self.defaults[key][:type]
    when 'boolean'
      [true, 1, "1", "t", "true"].include?(value)
    when 'decimal'
      BigDecimal.new(value.to_s)
    when 'integer'
      value.to_i
    when 'list'
      return value if value.is_a?(Array)
      value.split("\n").collect{ |v| v.split(',') }
    else
      value
    end
  end
  
  def self.method_missing(name, *args)
    name_stripped = name.to_s.gsub('?', '')
    if self.keys.include?(name_stripped)
      self[name_stripped]
    else
      super
    end
  end
  
end
