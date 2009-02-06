class ListingCalendarItem < ActiveRecord::Base
  belongs_to :listing_unit
  
  validates_format_of :availability,:with=>/^[0|A|U]{31}$/
  validates_presence_of :year,:month
  validates_numericality_of :year,:month
  
  def self.find_or_build(unit_id,year,month) 
    item = ListingCalendarItem.find(:first,:conditions=>"listing_unit_id = #{unit_id} and year = #{year} and month = #{month}")
    if item.nil?
      item = ListingCalendarItem.new(:month=>month,:year=>year,:listing_unit_id=>unit_id)
      item.save
    end
    return item
  end
  
  def self.check_for_auto_response(unit_id,start_date,stop_date)
    avb = ""
    if(start_date.month == stop_date.month)
      item = ListingCalendarItem.find_or_build(unit_id,start_date.year,start_date.month)
      avb = item.sub_availability(start_date.day,stop_date.day)
    else
      item_1 = ListingCalendarItem.find_or_build(unit_id,start_date.year,start_date.month)
      item_2 = ListingCalendarItem.find_or_build(unit_id,stop_date.year,stop_date.month)
      avb = "#{item_1.sub_availability(start_date.day,33)}#{item_2.sub_availability(1,stop_date.day)}"
    end
    
    if avb =~ /U/
      return "UNAVAILABLE"
    elsif avb =~ /^A+$/
      return "AVAILABLE"
    else
      return nil
    end
  end
  
  def self.mark_days(unit_id,start_date,stop_date,status)
    if(start_date.month == stop_date.month)
      item = ListingCalendarItem.find_or_build(unit_id,start_date.year,start_date.month)
      item.mark_days(start_date.day,stop_date.day,status)
    else
      item_1 = ListingCalendarItem.find_or_build(unit_id,start_date.year,start_date.month)
      item_2 = ListingCalendarItem.find_or_build(unit_id,stop_date.year,stop_date.month)
      item_1.mark_days(start_date.day,31,status)
      item_2.mark_days(1,stop_date.day,status)
    end
  end
  
  def initialize(attrs={})
    super
    self.availability ||= "0000000000000000000000000000000"
  end
  
  def sub_availability(day_1,day_2)
    self.availability[(day_1 - 1)...(day_2-1)]
  end
  
  def day_status(day)
    status = self.availability[day - 1]
    if status == "A"[0]
      return "AVAILABLE"
    elsif status == "U"[0]
      return "UNAVAILABLE"
    else
      nil
    end
  end
  
  def mark_days(day_1,day_2,status)
    marker = (status == "AVAILABLE") ? "A" : ((status == "UNAVAILABLE") ? "U" : "0")
    self.availability_will_change!
    while(day_1 <= day_2)
      self.availability[day_1 - 1] = marker[0]
      day_1 += 1
    end
    self.save!
  end
end
