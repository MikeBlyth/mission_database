class AddToTravel < ActiveRecord::Migration
  def self.up
    add_column :travels, :origin, :string
    add_column :travels, :destination, :string
    add_column :travels, :guesthouse, :string
    add_column :travels, :baggage, :integer
    add_column :travels, :extra_passengers, :integer
    add_column :travels, :confirmed, :date
    add_column :travels, :name, :string
  end

  def self.down
    remove_column :travels, :origin
    remove_column :travels, :destination
    remove_column :travels, :guesthouse
    remove_column :travels, :baggage
    remove_column :travels, :confirmed
    remove_column :travels, :name
  end
end
