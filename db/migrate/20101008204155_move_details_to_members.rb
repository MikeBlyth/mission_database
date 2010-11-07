class MoveDetailsToMembers < ActiveRecord::Migration
  def self.up
    add_column :members,  :status_code_id, :integer
    add_column :members,   :ministry_comment, :string
    add_column :members,   :qualifications, :string
    add_column :members,    :date_active, :date
    add_column :members,  :ministry_id, :integer
    add_column :members,  :education_id, :integer
    add_column :members,  :location_id, :integer
    add_column :members,  :employment_status_id, :integer
  end

  def self.down
    remove_column :members, :status_code_id
    remove_column :members,  :ministry_comment
    remove_column :members,  :qualifications
    remove_column :members,   :date_active
    remove_column :members, :ministry_id
    remove_column :members, :education_id
    remove_column :members, :location_id
    remove_column :members,  :employment_status_id
  end
end
