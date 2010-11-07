class CountryDefaultNigeria < ActiveRecord::Migration
  def self.up
     change_column :cities, :country, :string, :default => "Nigeria", :null => false
  end

  def self.down
     change_column :cities, :country, :string
  end
end
