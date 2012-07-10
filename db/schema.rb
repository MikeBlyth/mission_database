# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120710131757) do

  create_table "app_logs", :force => true do |t|
    t.string   "severity"
    t.string   "code"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "bloodtypes", :force => true do |t|
    t.string   "abo"
    t.string   "rh"
    t.string   "full"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "comment"
  end

  create_table "countries", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "nationality"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.boolean  "include_in_selection"
  end

  create_table "families", :force => true do |t|
    t.integer  "head_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "groups", :force => true do |t|
    t.string   "group_name"
    t.integer  "parent_group_id"
    t.string   "abbrev"
    t.boolean  "primary"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "groups_members", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "member_id"
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.string   "state"
    t.string   "city"
    t.string   "lga"
    t.float    "gps_latitude"
    t.float    "gps_longitude"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "members", :force => true do |t|
    t.string   "last_name"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "name"
    t.integer  "country_id"
    t.string   "emergency_contact_phone"
    t.string   "emergency_contact_email"
    t.string   "emergency_contact_name"
    t.string   "phone_1"
    t.string   "phone_2"
    t.string   "email_1"
    t.string   "email_2"
    t.integer  "location_id"
    t.string   "location_detail"
    t.date     "arrival_date"
    t.date     "departure_date"
    t.boolean  "receive_sms"
    t.boolean  "receive_email"
    t.boolean  "blood_donor"
    t.integer  "blood_type_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "members", ["name"], :name => "index_members_on_name"

  create_table "messages", :force => true do |t|
    t.text     "body"
    t.integer  "from_id"
    t.string   "code"
    t.integer  "confirm_time_limit"
    t.integer  "retries"
    t.integer  "retry_interval"
    t.integer  "expiration"
    t.integer  "response_time_limit"
    t.integer  "importance"
    t.integer  "to_groups"
    t.boolean  "send_email"
    t.boolean  "send_sms"
    t.integer  "user_id"
    t.string   "subject"
    t.string   "sms_only"
    t.integer  "following_up"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "sent_messages", :force => true do |t|
    t.integer  "message_id"
    t.integer  "member_id"
    t.integer  "msg_status"
    t.datetime "confirmed_time"
    t.string   "delivery_modes"
    t.string   "confirmed_mode"
    t.string   "confirmation_message"
    t.integer  "attempts"
    t.string   "gateway_message_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

end
