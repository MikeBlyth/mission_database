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
    first_line = self.count > lines ? self.count-lines : 0
    self.order('id ASC').offset(first_line).each do |line|
      reply << "#{line.id} #{line.created_at} #{line.code} #{line.description}\n"
    end
    reply
  end

end
