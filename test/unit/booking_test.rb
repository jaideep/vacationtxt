require File.dirname(__FILE__) + '/../test_helper'

class BookingTest < ActiveSupport::TestCase
  
  def test_necessary_attributes
    booking = Booking.new
    assert !booking.valid?
    booking.check_in = Date.today
    booking.check_out = Date.today
    assert booking.valid?
  end
  
  def test_tie_to_listing
    
  end
end
