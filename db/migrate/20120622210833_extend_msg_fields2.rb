class ExtendMsgFields2 < ActiveRecord::Migration
  def self.up
    change_column :messages, :body, :text
  end

  def self.down
    change_column :messages, :text, :body
  end
end
