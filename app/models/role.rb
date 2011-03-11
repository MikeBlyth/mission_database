# == Schema Information
# Schema version: 20110310144121
#
# Table name: roles
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  encrypted_key :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class Role < ActiveRecord::Base
end
