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

ActiveRecord::Schema.define(:version => 20101108210404) do

  create_table "bloodtypes", :force => true do |t|
    t.string   "abo"
    t.string   "rh"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full"
  end

  add_index "bloodtypes", ["full"], :name => "index_bloodtypes_on_full", :unique => true

  create_table "brands", :force => true do |t|
    t.string   "name"
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
    t.integer  "contact_type_id",                :default => 0,     :null => false
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
    t.string   "photos",          :limit => 50,  :default => ""
    t.boolean  "email_public",                   :default => false
    t.boolean  "phone_public",                   :default => false
    t.boolean  "skype_public",                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "member_id",                                         :null => false
  end

  add_index "contacts", ["id"], :name => "ID", :unique => true
  add_index "contacts", ["member_id"], :name => "member_id"

  create_table "contacts_sample", :force => true do |t|
    t.integer  "member_id"
    t.string   "email1"
    t.string   "email2"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "blog"
    t.string   "website"
    t.string   "photosite"
    t.string   "facebook"
    t.string   "contact_name"
    t.string   "address"
    t.string   "contact_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
  end

  add_index "employment_statuses", ["code"], :name => "index_employment_status_codes_on_code", :unique => true
  add_index "employment_statuses", ["description"], :name => "index_employment_status_codes_on_description", :unique => true

  create_table "families", :force => true do |t|
    t.integer  "head_id"
    t.integer  "status_id"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "home_address", :primary_key => "ID", :force => true do |t|
    t.string "SIM ID",        :limit => 6
    t.string "home_address"
    t.string "field_address"
    t.string "HLINE1",        :limit => 30
    t.string "HLINE2",        :limit => 30
    t.string "HCITY",         :limit => 22
    t.string "HSTATE",        :limit => 3
    t.string "SM",            :limit => 30
    t.string "HPOST",         :limit => 10
    t.string "HCTRY",         :limit => 3
    t.string "CM",            :limit => 25
    t.string "FLINE1",        :limit => 30
    t.string "FCITY",         :limit => 22
    t.string "FSTATE",        :limit => 3
    t.string "FSM",           :limit => 30
    t.string "FPOST",         :limit => 10
    t.string "FCTRY",         :limit => 25
  end

  add_index "home_address", ["SIM ID"], :name => "AddressMdNUMBER"

  create_table "locations", :force => true do |t|
    t.string   "description"
    t.integer  "city_id"
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
    t.integer  "country_id",           :null => false
    t.string   "first_name"
    t.integer  "bloodtype_id"
    t.string   "allergies"
    t.string   "medical_facts"
    t.string   "medications"
    t.integer  "status_id"
    t.string   "ministry_comment"
    t.string   "qualifications"
    t.date     "date_active"
    t.integer  "ministry_id"
    t.integer  "education_id"
    t.integer  "location_id"
    t.integer  "employment_status_id"
    t.boolean  "family_head"
  end

  add_index "members", ["bloodtype_id"], :name => "fk_bloodtypes"
  add_index "members", ["country_id"], :name => "fk_countries"

  create_table "members_travels", :id => false, :force => true do |t|
    t.integer  "member_id"
    t.integer  "travel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ministries", :force => true do |t|
    t.string   "description"
    t.integer  "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ministries", ["code"], :name => "index_ministry_codes_on_code", :unique => true
  add_index "ministries", ["description"], :name => "index_ministry_codes_on_description", :unique => true

  create_table "names_basic", :primary_key => "Key", :force => true do |t|
    t.string  "Family ID",        :limit => 50
    t.integer "family_id"
    t.string  "Last Name",        :limit => 20
    t.string  "First Name",       :limit => 20
    t.string  "Casual Name",      :limit => 50
    t.string  "SEX",              :limit => 1
    t.integer "Nationality_id"
    t.string  "Nationality Code", :limit => 3
    t.string  "Ministry",         :limit => 50
  end

  add_index "names_basic", ["Family ID"], :name => "Family ID"
  add_index "names_basic", ["Key"], :name => "Key_or_ID", :unique => true

  create_table "personnel", :primary_key => "Key", :force => true do |t|
    t.string  "StatusCode",             :limit => 1
    t.integer "MinistryCode",           :limit => 2
    t.integer "ministry_id"
    t.string  "MinistryComment",        :limit => 100
    t.integer "education_id"
    t.integer "EducationCode",          :limit => 2
    t.string  "QUALIFICAT",             :limit => 40
    t.integer "location_id"
    t.integer "LocationCode"
    t.date    "BIRTHDAY"
    t.string  "BLOODTYPE",              :limit => 3
    t.integer "bloodtype_id"
    t.integer "miss_status_id"
    t.string  "Missionary Status Code", :limit => 3
    t.date    "DATEACTIVE"
    t.float   "TERMLEN"
    t.date    "NEXT"
    t.date    "Departure Date"
    t.date    "DATEARRIVE"
    t.date    "DATEEMPLOY"
    t.date    "MODIFIED"
    t.string  "Term Status",            :limit => 50
    t.integer "ONLEAVE",                :limit => 1
    t.integer "statuscode_i"
  end

  create_table "personnel_details", :force => true do |t|
    t.integer  "status_code_id"
    t.string   "ministry_comment"
    t.string   "qualifications"
    t.date     "date_active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ministry_id"
    t.integer  "education_id"
    t.integer  "location_id"
    t.integer  "employment_status_id"
  end

  create_table "position_codes", :force => true do |t|
    t.string   "description"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
  end

  add_index "statuses", ["code"], :name => "index_status_codes_on_code", :unique => true
  add_index "statuses", ["description"], :name => "index_status_codes_on_description", :unique => true

  create_table "terms", :force => true do |t|
    t.integer  "member_id"
    t.integer  "status_id"
    t.integer  "location_id"
    t.integer  "ministry_id"
    t.date     "start_date"
    t.date     "end_date"
    t.date     "est_start_date"
    t.date     "est_end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.boolean  "with_spouse"
    t.boolean  "with_children"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
