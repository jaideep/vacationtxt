class RedoListingCalendarItems < ActiveRecord::Migration
  def self.up
    ListingCalendarItem.find(:all).each do |lci|
      lci.destroy
    end
    
    remove_index :listing_calendar_items,:name => "find_by_month_index"
    remove_column :listing_calendar_items,:start
    remove_column :listing_calendar_items,:stop
    remove_column :listing_calendar_items,:item_type
    add_column :listing_calendar_items,:year,:integer
    add_column :listing_calendar_items,:month,:integer
    add_column :listing_calendar_items,:availability,:string
    add_index :listing_calendar_items,["listing_id","year","month"],:name => "find_by_month_index"
  end

  def self.down
    remove_index :listing_calendar_items,:name => "find_by_month_index"
    remove_column :listing_calendar_items,:year
    remove_column :listing_calendar_items,:month
    remove_column :listing_calendar_items,:availability
    add_column :listing_calendar_items,:start,:date
    add_column :listing_calendar_items,:stop,:date
    add_column :listing_calendar_items,:item_type,:string
    add_index :listing_calendar_items,["listing_id", "start", "stop"],:name => "find_by_month_index"
  end
end
