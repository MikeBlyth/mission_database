class RemoveNationalityFromMembers < ActiveRecord::Migration
  def self.up
   remove_column :members, :nationality
   remove_column :personnel_details, :temp
  end

  def self.down
    add_column :members, :nationality, :string
    add_column :personnel_details, :temp, :string
  end
end
