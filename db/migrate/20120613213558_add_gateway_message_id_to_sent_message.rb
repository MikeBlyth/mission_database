class AddGatewayMessageIdToSentMessage < ActiveRecord::Migration
  def self.up
    add_column :sent_messages, :gateway_message_id, :string
    add_index  :sent_messages, :gateway_message_id
  end

  def self.down
    remove_index  :sent_messages, :gateway_message_id
    remove_column :sent_messages, :gateway_message_id
  end
end
