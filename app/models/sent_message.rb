# == Schema Information
# Schema version: 20120613213558
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
#  attempts             :integer         default(0)
#  gateway_message_id   :string(255)
#

class SentMessage < ActiveRecord::Base
  require 'mail'
  belongs_to :message
  belongs_to :member

  before_save :set_confirmed_time
  
  def set_confirmed_time  
    self.confirmed_time = Time.now
  end


end
