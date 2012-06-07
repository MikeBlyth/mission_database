class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :group_name
      t.string :type_of_group
      t.integer :parent_group_id
      t.timestamps
    end
    create_table :groups_members, :id => false do |t|
      t.integer :group_id
      t.integer :member_id
    end
  end

  def self.down
    drop_table :groups
    drop_table :groups_members
  end
end

