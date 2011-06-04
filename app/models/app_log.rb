# == Schema Information
# Schema version: 20110604193420
#
# Table name: app_logs
#
#  id          :integer         not null, primary key
#  severity    :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class AppLog < ActiveRecord::Base
  def self.tail(lines=10)
    reply = ''
    self.order('created_at DESC').limit(lines).each do |line|
      reply << "#{line.created_at} #{line.code} #{line.description}\n"
    end
    reply
  end

end
