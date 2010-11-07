class AddSomeIndexes < ActiveRecord::Migration
  def self.up
    add_index :bloodtypes, :full, :unique => true
    add_index :contact_types, :code, :unique => true
    add_index :contact_types, :description, :unique => true
    add_index :countries, :code, :unique => true
    add_index :countries, :name, :unique => true
    add_index :education_codes, :code, :unique => true
    add_index :education_codes, :description, :unique => true
    add_index :employment_status_codes, :code, :unique => true
    add_index :employment_status_codes, :description, :unique => true
    add_index :locations, :code, :unique => true
    add_index :locations, :description, :unique => true
    add_index :ministry_codes, :code, :unique => true
    add_index :ministry_codes, :description, :unique => true
    add_index :status_codes, :code, :unique => true
    add_index :status_codes, :description, :unique => true
    add_index :states, :name, :unique => true
  end

  def self.down
    remove_index :bloodtypes, :full
    remove_index :contact_types, :code
    remove_index :contact_types, :description
    remove_index :countries, :code
    remove_index :countries, :name
    remove_index :education_codes, :code
    remove_index :education_codes, :description
    remove_index :employment_status_codes, :code
    remove_index :employment_status_codes, :description
    remove_index :locations, :code
    remove_index :locations, :description
    remove_index :ministry_codes, :code
    remove_index :ministry_codes, :description
    remove_index :status_codes, :code
    remove_index :status_codes, :description
    remove_index :states, :description
  end
end
