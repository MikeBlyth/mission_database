class RenameNationalityToCountryId < ActiveRecord::Migration
  def self.up
    rename_column :members, :nationality_id, :country_id
  end

  def self.down
    rename_column :members, :country_id, :nationality_id  end
end
