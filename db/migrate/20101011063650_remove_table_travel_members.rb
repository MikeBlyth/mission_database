class RemoveTableTravelMembers < ActiveRecord::Migration
# This migration should not be included if travels-members relation is HABTM
  def self.up
      drop_table :members_travels
  end

  def self.down
      create_table :members_travels, :id => false do |t|
        t.integer :member_id
        t.integer :travel_id
      end
    end
end
