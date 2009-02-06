require 'test_helper'
require 'mocha'

class TripControllerTest < ActionController::TestCase
  def test_dont_duplicate_check_availability_if_trip_already_checking
    User.any_instance.stubs(:send_sms)
    Trip.any_instance.stubs(:send_sms)
    trip = Trip.find(1)
    trip.status = "QUERIED"
    trip.save!
    post :check_availability,{:id=>"1",:start_date=>"01/02/2008",:stop_date=>"01/03/2008",:bid=>"300"}
    trip = Trip.find(1)
    assert_not_equal "01/02/2008",trip.start.strftime("%m/%d/%Y")
    assert_not_equal "01/03/2008",trip.stop.strftime("%m/%d/%Y")
    assert_not_equal 300,trip.bid
  end
  
  def test_times_make_it_through_when_adding_listing
    post :add_listing,{"start_date"=>"02/04/2009", 
                       "commit"=>"Add to Trip", 
                       "stop_time"=>{"minute"=>"00", "hour"=>"11"}, 
                       "stop_date"=>"02/05/2009", 
                       "id"=>"1", 
                       "start_time"=>{"minute"=>"00", "hour"=>"18"}},{:user_id=>1}
    assert_redirected_to :action=>:welcome,:controller=>:main                   
    
    trip = Trip.find(:first,:conditions=>"",:order=>"id DESC")
    assert_equal 1,trip.listing_unit_id
    assert_equal "LISTING",trip.category
    
    assert_equal 2009,trip.start.year
    assert_equal 2,trip.start.month
    assert_equal 4,trip.start.day
    assert_equal 18,trip.start.hour
    assert_equal 0,trip.start.min
    
    assert_equal 2009,trip.stop.year
    assert_equal 2,trip.stop.month
    assert_equal 5,trip.stop.day
    assert_equal 11,trip.stop.hour
    assert_equal 0,trip.stop.min
  end
end
