class RemoveHealthInfoFromMembers < ActiveRecord::Migration
  def self.up
#    remove_column :members, :bloodtype_id
#    remove_column :members, :medications
#    remove_column :members, :allergies
#    remove_column :members, :medical_facts
    add_column    :health_data, :allergies, :string    
  end

  def self.down
    add_column :members, :bloodtype_id, :integer
    add_column :members, :medications, :string
    add_column :members, :allergies, :string
    add_column :members, :medical_facts, :string
    remove_column    :health_data, :allergies    
  end
end
