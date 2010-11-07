class MakeTravelMembersJoinTable < ActiveRecord::Migration
    def self.up
      create_table :members_travels, :id => false do |t|
        t.integer :member_id
        t.integer :travel_id
      end
    end

    def self.down
      drop_table :members_travels
    end
end
