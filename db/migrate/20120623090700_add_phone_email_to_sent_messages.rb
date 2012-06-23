class AddPhoneEmailToSentMessages < ActiveRecord::Migration
  def self.up
    add_column :sent_messages, :phone, :string
    add_column :sent_messages, :email, :string
  end

  def self.down
    remove_column :sent_messages, :email
    remove_column :sent_messages, :phone
  end
end
