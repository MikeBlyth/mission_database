class AddNamesToFamily < ActiveRecord::Migration
  def self.up
    add_column :families, :last_name, :string
    add_column :families, :first_name, :string
    add_column :families, :middle_name, :string
    add_column :families, :short_name, :string
    add_column :families, :name, :string
    add_column :families, :sim_id, :string
  end

  def self.down
    remove_column :families, :last_name
    remove_column :families, :first_name
    remove_column :families, :middle_name
    remove_column :families, :short_name
    remove_column :families, :display_name
    remove_column :families, :sim_id
  end
end
