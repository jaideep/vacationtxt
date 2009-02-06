# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090205184236) do

  create_table "bookings", :force => true do |t|
    t.date     "check_in"
    t.date     "check_out"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clicks", :force => true do |t|
    t.integer  "map_item_id"
    t.string   "target"
    t.datetime "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discounts", :force => true do |t|
    t.integer  "map_item_id"
    t.string   "coupon_code"
    t.integer  "priority"
    t.text     "description"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "sms_enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "extension"
  end

  create_table "images", :force => true do |t|
    t.integer  "user_id"
    t.integer  "listing_id"
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listing_calendar_items", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year"
    t.integer  "month"
    t.string   "availability"
    t.integer  "listing_unit_id"
  end

  add_index "listing_calendar_items", ["listing_unit_id", "year", "month"], :name => "find_by_month_index"
  add_index "listing_calendar_items", ["listing_unit_id"], :name => "index_listing_calendar_items_on_listing_unit_id"

  create_table "listing_units", :force => true do |t|
    t.integer  "listing_id"
    t.integer  "price"
    t.string   "strong_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bed_count"
    t.integer  "max_people"
    t.string   "description"
  end

  add_index "listing_units", ["listing_id"], :name => "index_listing_units_on_listing_id"
  add_index "listing_units", ["price"], :name => "search_index"

  create_table "listings", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.boolean  "active"
    t.float    "lat"
    t.float    "long"
    t.string   "description"
    t.string   "extension"
    t.string   "strong_name"
    t.integer  "user_id"
    t.string   "pricing_type"
    t.string   "region"
  end

  add_index "listings", ["user_id"], :name => "index_listings_on_user_id"

  create_table "map_items", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "website_url"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "lat"
    t.float    "long"
    t.integer  "code"
    t.boolean  "has_reservations"
    t.boolean  "can_order_online"
    t.boolean  "can_buy_tickets"
    t.boolean  "has_discount_coupon"
    t.boolean  "has_map"
    t.boolean  "verified"
    t.string   "phone"
    t.boolean  "reservable"
  end

  add_index "map_items", ["category"], :name => "index_map_items_on_category"
  add_index "map_items", ["name"], :name => "index_map_items_on_name"

  create_table "messages", :force => true do |t|
    t.string   "text"
    t.integer  "trip_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
  end

  add_index "messages", ["trip_id"], :name => "index_messages_on_trip_id"
  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"

  create_table "rentals", :force => true do |t|
    t.integer  "listing_id"
    t.float    "price"
    t.date     "confirmed_date"
    t.date     "rental_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "rental_date_end"
    t.integer  "user_id"
  end

  add_index "rentals", ["listing_id"], :name => "index_rentals_on_listing_id"
  add_index "rentals", ["user_id"], :name => "index_rentals_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "transactions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "renter_id"
    t.integer  "owner_id"
    t.integer  "listing_unit_id"
    t.integer  "price"
    t.datetime "start"
    t.datetime "stop"
    t.datetime "timestamp"
  end

  create_table "trips", :force => true do |t|
    t.integer  "user_id"
    t.string   "category"
    t.integer  "map_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "discount_id"
    t.datetime "start"
    t.datetime "stop"
    t.string   "status"
    t.integer  "bid"
    t.integer  "listing_unit_id"
  end

  add_index "trips", ["user_id"], :name => "index_trips_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password"
    t.string   "phone"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "time_zone"
    t.integer  "text_me_start_time"
    t.integer  "text_me_stop_time"
    t.integer  "call_me_start_time"
    t.integer  "call_me_stop_time"
    t.integer  "timeout"
    t.boolean  "notify_of_failed"
    t.string   "response_preference"
    t.integer  "default_search_single_count"
    t.integer  "default_search_double_count"
    t.integer  "default_search_max_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "message_waiting_id"
    t.datetime "message_waiting_timestamp"
  end

end
