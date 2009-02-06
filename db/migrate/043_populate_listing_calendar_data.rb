class PopulateListingCalendarData < ActiveRecord::Migration
  def self.up
    available_start_date = Date.parse("2008-05-23")
    available_stop_date = Date.parse("2008-05-25")
    
    unavailable_start_date = Date.parse("2008-05-15")
    unavailable_stop_date = Date.parse("2008-05-18")
    
    ListingCalendarItem.delete_all
    
    Listing.find(:all).each do |l|
      calItem = ListingCalendarItem.new
      calItem.listing_id = l.id
      calItem.item_type = ListingCalendarItem.open_type
      calItem.start = available_start_date
      calItem.stop = available_stop_date
      calItem.save!

      otherCalItem = ListingCalendarItem.new
      otherCalItem.listing_id = l.id
      otherCalItem.item_type = ListingCalendarItem.booked_type
      otherCalItem.start = unavailable_start_date
      otherCalItem.stop = unavailable_stop_date
      otherCalItem.save!      
    end
  end

  def self.down    
    ListingCalendarItem.delete_all
  end
end
