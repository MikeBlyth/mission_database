class CreatePersonnelData < ActiveRecord::Migration
  def self.up
    create_table :personnel_data do |t|
      t.integer :member_id
      t.string  :qualifications
      t.integer :education_id
      t.integer :employment_status_id
      t.date    :date_active
      t.string  :comments
      t.timestamps
    end
    remove_column :members, :qualifications
    remove_column :members, :education_id
    remove_column :members, :date_active
    remove_column :members, :employment_status_id
  end

  def self.down
    drop_table :personnel_data
    add_column :members, :qualifications, :string
    add_column :members, :education_id, :integer
    add_column :members, :date_active, :date
    add_column :members, :employment_status_id, :integer
  end
end
