class PersDataLongerComments < ActiveRecord::Migration
  def self.up
    change_column :personnel_data, :comments, :text, :null => true
    change_column :members, :ministry_comment, :text, :null => true
    add_column    :health_data, :comments, :text, :null => true
  end

  def self.down
    change_column :personnel_data, :comments, :string, :null => true
    change_column :members, :ministry_comment, :string, :null => true
    remove_column :health_data, :comments
  end
end
