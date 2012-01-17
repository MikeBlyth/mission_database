class SetDefaultsForTravel < ActiveRecord::Migration
  def self.up
    change_column :travels, :arrival, :boolean, :default => false
    change_column :travels, :with_spouse, :boolean, :default => false
    change_column :travels, :with_children, :boolean, :default => false
    change_column :travels, :term_passage, :boolean, :default => false
    change_column :travels, :personal, :boolean, :default => false
    change_column :travels, :ministry_related, :boolean, :default => false
    change_column :travels, :own_arrangements, :boolean, :default => false
  end

  def self.down
    change_column :travels, :arrival, :boolean
    change_column :travels, :with_spouse, :boolean
    change_column :travels, :with_children, :boolean
    change_column :travels, :term_passage, :boolean
    change_column :travels, :personal, :boolean
    change_column :travels, :ministry_related, :boolean
    change_column :travels, :own_arrangements, :boolean
  end
end
