require File.dirname(__FILE__) + '/../test_helper'

class ListingCalendarItemTest < ActiveSupport::TestCase
  
  def test_validation_with_zeros
    item = listing_calendar_items(:feb_item)
    assert item.valid?
    item.availability = "0000000000000000000000000000000"
    assert item.valid?
  end
  
  def test_validation_with_A
    item = listing_calendar_items(:feb_item)
    assert item.valid?
    item.availability = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    assert item.valid?
  end
  
  def test_validation_with_U
    item = listing_calendar_items(:feb_item)
    assert item.valid?
    item.availability = "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU"
    assert item.valid?
  end
  
  def test_validation_with_bad_characters
    item = listing_calendar_items(:feb_item)
    assert item.valid?
    item.availability = "UUUUUUUUUUUUUABCDUUUUUUUUUUUUUU"
    assert !item.valid?
  end
  
  def test_validation_too_short
    item = listing_calendar_items(:feb_item)
    assert item.valid?
    item.availability = "000000000000000000000000000000"
    assert !item.valid?
  end
  
  def test_validation_too_long
    item = listing_calendar_items(:feb_item)
    assert item.valid?
    item.availability = "00000000000000000000000000000000"
    assert !item.valid?
  end
  
  def test_extracting_subarray_from_availability
    item = listing_calendar_items(:feb_item)
    assert item.valid?
    item.availability = "00AA0000000000000AU000000000UUU"
    assert_equal "AA", item.sub_availability(3,5)
    assert_equal "0AU", item.sub_availability(17,20)
    assert_equal "UU", item.sub_availability(29,31)
  end
  
  def test_mark_days
    item = listing_calendar_items(:feb_item)
    assert item.valid?
    item.month = 3
    item.availability = "00AA0000000000000AU000000000UUU"
    assert_equal "00AA0000000000000AU000000000UUU",item.availability
    item.mark_days(6,8,"AVAILABLE")
    assert item.valid?
    item = ListingCalendarItem.find(item.id)
    assert_equal "00AA0AAA000000000AU000000000UUU",item.availability
    item.mark_days(12,15,"UNAVAILABLE")
    assert item.valid?
    item = ListingCalendarItem.find(item.id)
    assert_equal "00AA0AAA000UUUU00AU000000000UUU",item.availability
  end
  
  def test_new_item_is_valid
    item = ListingCalendarItem.new(:listing_unit_id=>1,:month=>1,:year=>2009)
    assert item.valid?
  end
  
  def test_marking_days_by_class_method
    item = listing_calendar_items(:feb_item)
    item.availability = "00000000000000000AU000000000UUU"
    assert item.valid?
    item.save
    ListingCalendarItem.mark_days(item.listing_unit_id,Date.civil(item.year,item.month,2),Date.civil(item.year,item.month,3),"AVAILABLE")
    item = ListingCalendarItem.find(item.id)
    assert_equal "0AA00000000000000AU000000000UUU",item.availability
  end
  
  def test_get_day_status
    item = listing_calendar_items(:feb_item)
    item.availability = "00AA0000000000000AU000000000UUU"
    assert_nil item.day_status(1)
    assert_equal "AVAILABLE", item.day_status(4)
    assert_equal "UNAVAILABLE", item.day_status(30)
  end
  
  def test_check_for_auto_response_with_all_zeros
    item = ListingCalendarItem.new(:listing_unit_id=>13,:year=>2008,:month=>1,:availability=>"0000000000000000000000000000000")
    item.save!
    response = ListingCalendarItem.check_for_auto_response(13,DateTime.civil(2008,1,3,8,21),DateTime.civil(2008,1,9,8,21))
    assert_nil response
  end
  
  def test_check_for_auto_response_with_forced_build
    response = ListingCalendarItem.check_for_auto_response(13,DateTime.civil(2008,1,3,8,21),DateTime.civil(2008,1,9,8,21))
    assert_nil response
  end
  
  def test_check_for_auto_response_with_forced_build_same_day
    response = ListingCalendarItem.check_for_auto_response(13,DateTime.civil(2008,1,9,8,21),DateTime.civil(2008,1,9,8,21))
    assert_nil response
  end
  
  def test_check_for_auto_response_with_all_As
    item = ListingCalendarItem.new(:listing_unit_id=>13,:year=>2008,:month=>1,:availability=>"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
    item.save!
    response = ListingCalendarItem.check_for_auto_response(13,DateTime.civil(2008,1,3,8,21),DateTime.civil(2008,1,9,8,21))
    assert_equal "AVAILABLE",response
  end
  
  def test_check_for_auto_response_with_all_Us
    item = ListingCalendarItem.new(:listing_unit_id=>13,:year=>2008,:month=>1,:availability=>"UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU")
    item.save!
    response = ListingCalendarItem.check_for_auto_response(13,DateTime.civil(2008,1,3,8,21),DateTime.civil(2008,1,9,8,21))
    assert_equal "UNAVAILABLE",response
  end
  
  def test_find_or_build_when_item_exists
    listing = ListingUnit.find(:first,:conditions=>"")
    new_cal_item = ListingCalendarItem.new(:month=>12,:year=>2010,:listing_unit_id=>listing.id)
    new_cal_item.save!
    init_count = ListingCalendarItem.all.size
    cal_item = ListingCalendarItem.find_or_build(listing.id,2010,12)
    assert_not_nil cal_item
    assert_equal cal_item.id,new_cal_item.id
    assert_equal init_count,ListingCalendarItem.all.size
  end
  
  def test_find_or_build_when_item_does_not_yet_exist
    listing = ListingUnit.find(:first,:conditions=>"")
    init_count = ListingCalendarItem.all.size
    cal_item = ListingCalendarItem.find_or_build(listing.id,2010,12)
    assert_not_nil cal_item
    assert_equal cal_item.month,12
    assert_equal cal_item.year,2010
    assert_equal init_count + 1,ListingCalendarItem.all.size
  end
end
