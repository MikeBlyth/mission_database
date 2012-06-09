# == Schema Information
# Schema version: 20120608071630
#
# Table name: sent_messages
#
#  id                   :integer         not null, primary key
#  message_id           :string(255)
#  member_id            :string(255)
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
