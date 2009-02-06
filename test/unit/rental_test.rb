require File.dirname(__FILE__) + '/../test_helper'

class RentalTest < ActiveSupport::TestCase
  
  def test_validate_required_attributes
    new_rental = Rental.new
    assert !new_rental.valid?
    assert new_rental.errors.invalid?(:user_id)
    assert new_rental.errors.invalid?(:listing_id)
    assert new_rental.errors.invalid?(:price)
    assert new_rental.errors.invalid?(:confirmed_date)
    assert new_rental.errors.invalid?(:rental_date)
    assert new_rental.errors.invalid?(:rental_date_end)
  end
  
  def test_attached_customer_and_listing
    honeymoon = rentals(:charvels_honeymoon)
    vacation = rentals(:charvels_vacation)
    business_trip = rentals(:charvels_business_trip)
    
    charvel = users(:charvel)
    assert_equal charvel,honeymoon.user
    assert_equal charvel,vacation.user
    assert_equal charvel,business_trip.user
    
    cabin = listings(:ethans_cabin)
    assert_equal cabin,honeymoon.listing 
    assert_equal cabin,vacation.listing
    assert_equal cabin,business_trip.listing
  end
  
end
