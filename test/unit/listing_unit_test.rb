require 'test_helper'

class ListingUnitTest < ActiveSupport::TestCase
  def test_beds_numericality
    condo = listing_units(:ethans_condo)
    assert condo.valid?
    condo.bed_count = "dog-fish"
    assert !condo.valid?
    condo.bed_count = 1
    assert condo.valid?
  end
  
  def test_capacity_numericality
    condo = listing_units(:ethans_condo)
    assert condo.valid?
    condo.max_people = "cat-bird"
    assert !condo.valid?
    condo.max_people = 1
    assert condo.valid?
  end
  
  def test_defaults
    listing = ListingUnit.new
    assert_equal 0,listing.bed_count
    assert_equal 0,listing.max_people
  end
  
  def test_invalid_price
    condo = listing_units(:ethans_condo)
    assert condo.valid?
    condo.price = "cat"
    assert !condo.valid?
    condo.price = 150
    assert condo.valid?
  end
  
  def test_find_calendar_item_for_April
     condo = listing_units(:ethans_condo)
     assert_not_nil condo.get_calendar_item(2008,4)
   end

   def test_find_calendar_item_for_May
     condo = listing_units(:ethans_condo)
     assert_not_nil condo.get_calendar_item(2008,4)
   end

   def test_find_calendar_item_that_doesnt_exist_yet
     condo = listing_units(:ethans_condo)
     item = condo.get_calendar_item(2009,1)
     assert_not_nil item
     assert_equal "0000000000000000000000000000000",item.availability
     assert_equal condo.id,item.listing_unit_id
   end

   def test_status_by_date_when_available
     condo = listing_units(:ethans_condo)
     assert_equal "AVAILABLE",condo.availability_on(Date.civil(2008,5,21),Date.civil(2008,5,25))
   end

   def test_status_by_date_including_checkout
     condo = listing_units(:ethans_condo)
     assert_equal "AVAILABLE",condo.availability_on(Date.civil(2008,5,2),Date.civil(2008,5,3))
   end

   def test_status_by_date_when_available_overlap
     condo = listing_units(:ethans_condo)
     assert_nil condo.availability_on(Date.civil(2008,5,19),Date.civil(2008,5,21))
   end

   def test_status_by_date_when_unavailable
     condo = listing_units(:ethans_condo)
     assert_equal "UNAVAILABLE",condo.availability_on(Date.civil(2008,5,13),Date.civil(2008,5,14))
   end

   def test_status_by_date_when_unavailable_overlap
     condo = listing_units(:ethans_condo)
     assert_equal "UNAVAILABLE",condo.availability_on(Date.civil(2008,5,10),Date.civil(2008,5,13))
   end

   def test_status_by_date_when_overlapping_both
     condo = listing_units(:ethans_condo)
     assert_equal "UNAVAILABLE",condo.availability_on(Date.civil(2008,5,7),Date.civil(2008,5,13))
   end

   def test_status_by_date_when_neither
     condo = listing_units(:ethans_condo)
     assert_nil condo.availability_on(Date.civil(2008,5,17),Date.civil(2008,5,18))
   end

   def test_available_status_spanning_months
     condo = listing_units(:ethans_condo)
     assert_equal "AVAILABLE",condo.availability_on(Date.civil(2008,5,30),Date.civil(2008,6,2))
   end

   def test_unavailable_status_spanning_months
     condo = listing_units(:ethans_condo)
     assert_equal "UNAVAILABLE",condo.availability_on(Date.civil(2008,5,30),Date.civil(2008,6,7))
   end

   def test_neither_status_spanning_months
     condo = listing_units(:ethans_condo)
     assert_nil condo.availability_on(Date.civil(2008,5,30),Date.civil(2008,6,3))
   end
end
