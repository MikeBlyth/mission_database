class AddNationalityIdToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :nationality_id, :integer
  end

  def self.down
    remove_column :members, :nationality_id
  end
end
