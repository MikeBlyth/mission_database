class RemoveNameFromTravels < ActiveRecord::Migration
  def self.up
    rename_column :travels, :name, :other_travelers
    add_column :travels, :with_spouse, :boolean
    add_column :travels, :with_children, :boolean
  end

  def self.down
    rename_column :travels, :other_travelers, :name
    remove_column :travels, :with_spouse
    remove_column :travels, :with_children
  end
end
