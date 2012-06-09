class CreateMsgToMember < ActiveRecord::Migration
  def self.up
    create_table :sent_messages do |t|
      t.integer :message_id
      t.integer :member_id
      t.integer :status
      t.datetime :confirmed_time
      t.string :delivery_modes
      t.string :confirmed_mode
      t.string :confirmation_message
    end
    add_index  :sent_messages, :message_id
    add_index  :sent_messages, :member_id

  end

  def self.down
    drop_table :sent_messages
  end
end
