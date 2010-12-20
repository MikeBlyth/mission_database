class AddNameOverrideToFamily < ActiveRecord::Migration
  def self.up
    add_column :families, :name_override, :boolean
  end

  def self.down
    remove_column :families, :name_override
  end
end
