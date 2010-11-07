class ChangePersonsToMemberId < ActiveRecord::Migration
  def self.up
   change_table :contacts do |t| 
     t.rename :person, :member_id 
   end 
  end

  def self.down
   change_table :contacts do |t| 
     t.rename :member_id, :person 
   end 
  end
end
