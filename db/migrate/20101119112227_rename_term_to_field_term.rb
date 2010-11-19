class RenameTermToFieldTerm < ActiveRecord::Migration
  def self.up
    rename_table :terms, :field_terms
  end

  def self.down
    rename_table :field_terms, :terms
  end
end
