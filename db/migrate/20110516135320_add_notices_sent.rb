class AddNoticesSent < ActiveRecord::Migration
  def self.up
    add_column :travels, :reminder_sent, :date
    add_column :families, :summary_sent, :date
  end

  def self.down
    remove_column :travels, :reminder_sent
    remove_column :families, :summary_sent
  end
end
