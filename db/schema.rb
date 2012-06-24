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

ActiveRecord::Schema.define(:version => 20120624072326) do

  create_table "app_logs", :force => true do |t|
    t.string   "severity"
    t.string   "code"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bloodtypes", :force => true do |t|
    t.string   "abo"
    t.string   "rh"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full"
  end

  add_index "bloodtypes", ["full"], :name => "index_bloodtypes_on_full", :unique => true

  create_table "calendar_events", :force => true do |t|
    t.datetime "date"
    t.string   "event"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.string   "state"
    t.string   "country",    :default => "NG", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "contact_types", :force => true do |t|
    t.integer  "code"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contact_types", ["code"], :name => "index_contact_types_on_code", :unique => true
  add_index "contact_types", ["description"], :name => "index_contact_types_on_description", :unique => true

  create_table "contacts", :force => true do |t|
    t.integer  "contact_type_id"
    t.string   "contact_name"
    t.string   "address"
    t.string   "email_1",         :limit => 40
    t.string   "email_2",         :limit => 40
    t.string   "phone_1",         :limit => 15
    t.string   "phone_2",         :limit => 15
    t.string   "blog",            :limit => 100
    t.string   "other_website",   :limit => 100
    t.string   "skype",           :limit => 20
    t.string   "facebook",        :limit => 60
    t.string   "photos",          :limit => 50
    t.boolean  "email_private",                  :default => false
    t.boolean  "phone_private",                  :default => false
    t.boolean  "skype_private",                  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "member_id",                                         :null => false
    t.boolean  "is_primary"
  end

  add_index "contacts", ["id"], :name => "ID", :unique => true
  add_index "contacts", ["member_id"], :name => "member_id"

  create_table "countries", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "nationality"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "include_in_selection"
  end

  add_index "countries", ["code"], :name => "index_countries_on_code", :unique => true
  add_index "countries", ["name"], :name => "index_countries_on_name", :unique => true

  create_table "educations", :force => true do |t|
    t.string   "description"
    t.integer  "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "educations", ["code"], :name => "index_education_codes_on_code", :unique => true
  add_index "educations", ["description"], :name => "index_education_codes_on_description", :unique => true

  create_table "employment_statuses", :force => true do |t|
    t.string   "description"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "mk_default"
    t.boolean  "umbrella",    :default => false
    t.boolean  "org_member",  :default => true
    t.boolean  "current_use", :default => true
    t.boolean  "child"
  end

  add_index "employment_statuses", ["code"], :name => "index_employment_status_codes_on_code", :unique => true
  add_index "employment_statuses", ["description"], :name => "index_employment_status_codes_on_description", :unique => true

  create_table "families", :force => true do |t|
    t.integer  "head_id"
    t.integer  "status_id"
    t.integer  "residence_location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_name"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "short_name"
    t.string   "name"
    t.boolean  "name_override",         :default => false
    t.string   "sim_id"
    t.date     "summary_sent"
    t.string   "tasks"
  end

  create_table "field_terms", :force => true do |t|
    t.integer  "member_id"
    t.integer  "employment_status_id"
    t.integer  "primary_work_location_id"
    t.integer  "ministry_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "beginning_travel_id"
    t.integer  "ending_travel_id"
    t.boolean  "end_estimated"
    t.boolean  "start_estimated"
  end

  create_table "groups", :force => true do |t|
    t.string   "group_name"
    t.string   "type_of_group"
    t.integer  "parent_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbrev"
    t.boolean  "primary"
  end

  create_table "groups_members", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "member_id"
  end

  create_table "health_data", :force => true do |t|
    t.integer  "member_id"
    t.integer  "bloodtype_id"
    t.string   "current_meds"
    t.string   "issues"
    t.string   "allergies"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comments"
  end

  create_table "locations", :force => true do |t|
    t.string   "description"
    t.integer  "city_id",     :default => 999999
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "code"
  end

  add_index "locations", ["code"], :name => "index_locations_on_code", :unique => true
  add_index "locations", ["description"], :name => "index_locations_on_description", :unique => true

  create_table "members", :force => true do |t|
    t.string   "last_name"
    t.string   "short_name"
    t.string   "sex"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "middle_name"
    t.integer  "family_id"
    t.date     "birth_date"
    t.integer  "spouse_id"
    t.integer  "country_id"
    t.string   "first_name"
    t.integer  "status_id"
    t.text     "ministry_comment"
    t.integer  "ministry_id"
    t.integer  "residence_location_id"
    t.string   "name"
    t.boolean  "name_override"
    t.boolean  "child",                         :default => false
    t.integer  "work_location_id"
    t.string   "temporary_location"
    t.date     "temporary_location_from_date"
    t.date     "temporary_location_until_date"
    t.text     "school"
    t.integer  "school_grade"
    t.string   "photo"
    t.boolean  "in_country"
    t.string   "reported_location"
    t.datetime "reported_location_date"
  end

  add_index "members", ["country_id"], :name => "fk_countries"
  add_index "members", ["family_id"], :name => "index_members_on_family_id"
  add_index "members", ["name"], :name => "index_members_on_name", :unique => true

  create_table "members_travels", :id => false, :force => true do |t|
    t.integer "member_id"
    t.integer "travel_id"
  end

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
    t.string   "to_groups"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "send_email"
    t.boolean  "send_sms"
    t.integer  "user_id"
    t.string   "subject"
    t.string   "sms_only"
  end

  create_table "ministries", :force => true do |t|
    t.string   "description"
    t.integer  "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ministries", ["code"], :name => "index_ministry_codes_on_code", :unique => true
  add_index "ministries", ["description"], :name => "index_ministry_codes_on_description", :unique => true

  create_table "pers_tasks", :force => true do |t|
    t.string   "task"
    t.boolean  "pipeline"
    t.boolean  "orientation"
    t.boolean  "start_of_term"
    t.boolean  "end_of_term"
    t.boolean  "end_of_service"
    t.boolean  "alert"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "personnel_data", :force => true do |t|
    t.integer  "member_id"
    t.string   "qualifications"
    t.text     "comments"
    t.integer  "employment_status_id"
    t.integer  "education_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date_active"
    t.date     "est_end_of_service"
    t.date     "end_nigeria_service"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "encrypted_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sent_messages", :force => true do |t|
    t.integer  "message_id"
    t.integer  "member_id"
    t.integer  "msg_status"
    t.datetime "confirmed_time"
    t.string   "delivery_modes"
    t.string   "confirmed_mode"
    t.string   "confirmation_message"
    t.integer  "attempts",             :default => 0
    t.string   "gateway_message_id"
  end

  add_index "sent_messages", ["gateway_message_id"], :name => "index_sent_messages_on_gateway_message_id"
  add_index "sent_messages", ["member_id"], :name => "index_sent_messages_on_member_id"
  add_index "sent_messages", ["message_id"], :name => "index_sent_messages_on_message_id"

  create_table "site_settings", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "site_settings", ["name"], :name => "index_site_settings_on_name"

  create_table "states", :force => true do |t|
    t.string   "name"
    t.string   "zone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "states", ["name"], :name => "index_states_on_name", :unique => true

  create_table "statuses", :force => true do |t|
    t.string   "description"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
    t.boolean  "on_field"
    t.boolean  "pipeline"
    t.boolean  "leave"
    t.boolean  "home_assignment"
  end

  add_index "statuses", ["code"], :name => "index_status_codes_on_code", :unique => true
  add_index "statuses", ["description"], :name => "index_status_codes_on_description", :unique => true

  create_table "travels", :force => true do |t|
    t.date     "date"
    t.string   "purpose"
    t.date     "return_date"
    t.string   "flight"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "origin"
    t.string   "destination"
    t.string   "guesthouse"
    t.integer  "baggage"
    t.integer  "total_passengers"
    t.date     "confirmed"
    t.string   "other_travelers"
    t.boolean  "with_spouse",      :default => false
    t.boolean  "with_children",    :default => false
    t.boolean  "arrival",          :default => false
    t.time     "time"
    t.time     "return_time"
    t.string   "driver_accom"
    t.string   "comments"
    t.boolean  "term_passage",     :default => false
    t.boolean  "personal",         :default => false
    t.boolean  "ministry_related", :default => false
    t.boolean  "own_arrangements", :default => false
    t.date     "reminder_sent"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin",                 :default => false
    t.string   "encrypted_db_password"
    t.boolean  "medical"
    t.boolean  "personnel"
    t.boolean  "travel"
    t.boolean  "member"
    t.boolean  "immigration"
    t.boolean  "asst_personnel"
    t.boolean  "security"
  end

  add_index "users", ["name"], :name => "index_users_on_name", :unique => true

end
