# == Schema Information
# Schema version: 20120609195703
#
# Table name: sent_messages
#
#  id                   :integer         not null, primary key
#  message_id           :integer
#  member_id            :integer
#  status               :integer
#  confirmed_time       :datetime
#  delivery_modes       :string(255)
#  confirmed_mode       :string(255)
#  confirmation_message :string(255)
#

class SentMessage < ActiveRecord::Base
  belongs_to :message
  belongs_to :member
end
