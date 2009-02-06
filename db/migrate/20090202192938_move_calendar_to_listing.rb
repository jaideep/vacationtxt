class MoveCalendarToListing < ActiveRecord::Migration
  def self.up
    ListingCalendarItem.all.each do |lu|
      lu.destroy
    end
    
    remove_index :listing_calendar_items,:name => "find_by_month_index"
    remove_index :listing_calendar_items,"listing_id"
    remove_column :listing_calendar_items,:listing_id
    
    add_column :listing_calendar_items,:listing_unit_id,:integer
    add_index :listing_calendar_items,["listing_unit_id", "year", "month"], :name => "find_by_month_index"
    add_index :listing_calendar_items,"listing_unit_id"
  end

  def self.down
  
    remove_index :listing_calendar_items,:name => "find_by_month_index"
    remove_index :listing_calendar_items,"listing_unit_id"
    remove_column :listing_calendar_items,:listing_unit_id,:integer
    
    add_column :listing_calendar_items,:listing_id
    add_index :listing_calendar_items,["listing_id", "year", "month"], :name => "find_by_month_index"
    add_index :listing_calendar_items,"listing_id"
  end
end
