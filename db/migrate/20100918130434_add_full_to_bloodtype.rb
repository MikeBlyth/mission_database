class AddFullToBloodtype < ActiveRecord::Migration
  def self.up
    add_column :bloodtypes, :full, :string
  end

  def self.down
    remove_column :bloodtypes, :full
  end
end
