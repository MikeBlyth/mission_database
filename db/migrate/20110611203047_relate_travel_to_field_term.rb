class RelateTravelToFieldTerm < ActiveRecord::Migration
  def self.up
    add_column :field_terms, :beginning_travel_id, :integer
    add_column :field_terms, :ending_travel_id, :integer
    
  end

  def self.down
    remove_column :field_terms, :beginning_travel_id
    remove_column :field_terms, :ending_travel_id
  end
end
