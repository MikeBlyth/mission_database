class AddSchoolInfoForChildren < ActiveRecord::Migration
  def self.up
    add_column :members, :school, :text
    add_column :members, :school_grade, :integer
  end

  def self.down
    drop_column :members, :school
    drop_column :members, :grade
  end
end
