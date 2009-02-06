class AddIndexToCalendarListings < ActiveRecord::Migration
  def self.up
    add_index :listing_calendar_items, "listing_id", :unique=>false
    add_index :listing_calendar_items, ["listing_id", "start", "stop"], :name=>"find_by_month_index", :unique=>true
  end

  def self.down
    remove_index :listing_calendar_items, "listing_id"
    remove_index :listing_calendar_items, :name=>"find_by_month_index" 
  end
end
