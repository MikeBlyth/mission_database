class AddPhotosToMember < ActiveRecord::Migration
  def self.up
    add_column    :members, :photo, :string, :null => true
  end

  def self.down
    remove_column    :members, :photo
  end

end
