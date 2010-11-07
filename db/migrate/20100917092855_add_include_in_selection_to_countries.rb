class AddIncludeInSelectionToCountries < ActiveRecord::Migration
  def self.up
    add_column :countries, :include_in_selection, :boolean
  end

  def self.down
    remove_column :countries, :include_in_selection
  end
end
