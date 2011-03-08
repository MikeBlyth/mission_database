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

ActiveRecord::Schema.define(:version => 20110308202950) do

  create_table "bloodtypes", :force => true do |t|
    t.string   "abo"
    t.string   "rh"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full"
  end

  add_index "bloodtypes", ["full"], :name => "index_bloodtypes_on_full", :unique => true

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
  end

  add_index "employment_statuses", ["code"], :name => "index_employment_status_codes_on_code", :unique => true
  add_index "employment_statuses", ["description"], :name => "index_employment_status_codes_on_description", :unique => true

  create_table "families", :force => true do |t|
    t.integer  "head_id"
    t.integer  "status_id",             :default => 999999
    t.integer  "residence_location_id", :default => 999999
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_name"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "short_name"
    t.string   "name"
    t.string   "sim_id"
    t.boolean  "name_override"
  end

  create_table "field_terms", :force => true do |t|
    t.integer  "member_id"
    t.integer  "primary_work_location_id", :default => 999999
    t.integer  "ministry_id",              :default => 999999
    t.date     "start_date"
    t.date     "end_date"
    t.date     "est_start_date"
    t.date     "est_end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "employment_status_id",     :default => 999999
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
    t.integer  "country_id",                    :default => 999999
    t.string   "first_name"
    t.integer  "bloodtype_id",                  :default => 999999
    t.string   "allergies"
    t.string   "medical_facts"
    t.string   "medications"
    t.integer  "status_id",                     :default => 999999
    t.string   "ministry_comment"
    t.string   "qualifications"
    t.date     "date_active"
    t.integer  "ministry_id",                   :default => 999999
    t.integer  "education_id",                  :default => 999999
    t.integer  "residence_location_id",         :default => 999999
    t.integer  "employment_status_id",          :default => 999999
    t.string   "name"
    t.boolean  "name_override"
    t.boolean  "child"
    t.integer  "work_location_id"
    t.string   "temporary_location"
    t.date     "temporary_location_from_date"
    t.date     "temporary_location_until_date"
  end

  add_index "members", ["bloodtype_id"], :name => "fk_bloodtypes"
  add_index "members", ["country_id"], :name => "fk_countries"
  add_index "members", ["family_id"], :name => "index_members_on_family_id"
  add_index "members", ["name"], :name => "index_members_on_name", :unique => true
  add_index "members", ["status_id"], :name => "index_members_on_status_id"

  create_table "ministries", :force => true do |t|
    t.string   "description"
    t.integer  "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ministries", ["code"], :name => "index_ministry_codes_on_code", :unique => true
  add_index "ministries", ["description"], :name => "index_ministry_codes_on_description", :unique => true

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
    t.boolean  "arrival"
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
  end

  add_index "users", ["name"], :name => "index_users_on_name", :unique => true

end
