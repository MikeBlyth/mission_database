class AddAttemptsToSentMessage < ActiveRecord::Migration
  def self.up
    add_column :sent_messages, :attempts, :integer, :default=>0
  end

  def self.down
    remove_column :sent_messages, :attempts
  end
end
