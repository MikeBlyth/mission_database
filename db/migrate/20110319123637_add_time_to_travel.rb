class AddTimeToTravel < ActiveRecord::Migration
  def self.up
    add_column :travels, :time, :time
    add_column :travels, :return_time, :time
    add_column :travels, :driver_accom, :string
    add_column :travels, :comments, :string
    add_column :travels, :term_passage, :boolean
    add_column :travels, :personal, :boolean
    add_column :travels, :ministry_related, :boolean
  end

  def self.down
    remove_column :travels, :ministry_related
    remove_column :travels, :personal
    remove_column :travels, :comments
    remove_column :travels, :term_passage
    remove_column :travels, :driver_accom
    remove_column :travels, :time
    remove_column :travels, :return_time
  end
end
