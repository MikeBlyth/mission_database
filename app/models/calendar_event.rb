# == Schema Information
# Schema version: 20110413013605
#
# Table name: calendar_events
#
#  id         :integer         not null, primary key
#  date       :datetime
#  event      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class CalendarEvent < ActiveRecord::Base
# About as simple as a model as can be. Nothing to validate, really!
end
