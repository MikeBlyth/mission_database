class ChangeContactTypeIdDefaultToNil < ActiveRecord::Migration
  def self.up
    change_column :contacts, :contact_type_id, :integer, :default=>nil, :null => true
  end

  def self.down
    change_column :contacts, :contact_type_id, :integer, :default=>0, :null => false
  end
end
