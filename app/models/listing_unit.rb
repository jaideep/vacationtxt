class ListingUnit < ActiveRecord::Base
  belongs_to :listing
  has_many :listing_calendar_items
  has_many :trips
  
  validates_presence_of :price,:bed_count,:max_people,:strong_name
  validates_numericality_of :price,:bed_count,:max_people
  
  def initialize(attrs={})
    super
    self.bed_count ||= 0
    self.max_people ||= 0
    self.price ||= 200
  end
  
  def get_calendar_item(year,month)
    ListingCalendarItem.find_or_build(self.id,year,month)
  end
  
  def availability_on(start_date,stop_date)
    ListingCalendarItem.check_for_auto_response(self.id,start_date,stop_date)
  end
  
  def book!(start_date,stop_date)
    ListingCalendarItem.mark_days(self.id,start_date,(stop_date - 1.day),"UNAVAILABLE")
  end
  
  def unbook!(start_date,stop_date)
    ListingCalendarItem.mark_days(self.id,start_date,(stop_date - 1.day),"CHECK")
  end
  
  def send_owner_threaded_message(trip_id,msg)
    self.listing.send_owner_threaded_message(trip_id,msg)
  end
  
  def cancel_trip(trip_id,msg)
    self.listing.cancel_trip(trip_id,msg)
  end
  
  def name
    if self.listing.listing_units.size > 1
      "#{self.strong_name} in #{self.listing.strong_name}"
    else
      self.listing.strong_name
    end
  end
  
  def number
    self.phone
  end
  
  def phone
    self.listing.phone
  end
  
  def address
    self.listing.address
  end
  
  def long
    self.listing.long
  end
  
  def lat
    self.listing.lat
  end

  def category
    self.listing.category
  end

  def code
    self.listing.code
  end

  def website_url
    self.listing.website_url
  end

  def thumbnail_url
    self.listing.thumbnail_url
  end

  def has_picture?
    self.listing.has_picture?
  end
  
  def reservable?
    self.listing.reservable?
  end
  
  def up_for_bid?
    self.listing.up_for_bid?
  end
end
