require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase 
  def test_validate_required_attributes
    new_cust = User.new
    assert !new_cust.valid?
    assert new_cust.errors.invalid?(:password)
    assert new_cust.errors.invalid?(:name)
    assert new_cust.errors.invalid?(:email)
    assert new_cust.errors.invalid?(:phone)
    assert new_cust.errors.invalid?(:street_address)
    assert new_cust.errors.invalid?(:city)
    assert new_cust.errors.invalid?(:state)
    assert new_cust.errors.invalid?(:zip)
    assert !new_cust.errors.invalid?(:response_preference) 
  end
  
  def test_validate_unique_email
    nadia = users(:nadia)
    assert_equal(User.find(4),nadia)
    assert nadia.valid?
    nadia.email = users(:charvel).email
    assert !nadia.valid?
    assert nadia.errors.invalid?(:email)
  end
  
  def test_rentals_array
    charvel = users(:charvel)
    charvels_rentals = Rental.find(:all, :conditions => ["user_id = ?",charvel.id])
    assert_equal charvel.rentals.count, charvels_rentals.size
  end  
  
  def test_authenticate_with_valid_credentials
    charvel = users(:charvel)
    assert_not_nil User.auth(charvel.email,charvel.password)
  end
  
  def test_authenticate_with_invalid_password
    charvel = users(:charvel)
    assert_nil User.auth(charvel.email,"not charvel's password")
  end
  
  def test_authenticate_with_nonexistant_user
    assert_nil User.auth("garbage in","garbage out")
  end
  
  def test_default_search_params
    cust = User.new
    assert_equal 1,cust.default_search_single_count
    assert_equal 1,cust.default_search_double_count
    assert_equal 500, cust.default_search_max_price
  end
  
  def test_listings_array
    ethan = users(:ethan)
    ethans_listings = Listing.find(:all, :conditions => ["user_id = ?",ethan.id])
    assert_equal ethan.listings.count, ethans_listings.size
  end  
  
  def test_authenticate_with_valid_credentials
    ethan = users(:ethan)
    assert_not_nil User.auth(ethan.email,ethan.password)
  end
  
  def test_authenticate_with_invalid_password
    ethan = users(:ethan)
    assert_nil User.auth(ethan.email,"not ethan's password")
  end
  
  def test_authenticate_with_nonexistant_user
    assert_nil User.auth("garbage in","garbage out")
  end
  
  def test_active_listings
    ethan = users(:ethan)
    assert_equal 3, ethan.active_listings.size
  end
  
  def test_inactive_listings
    ethan = users(:ethan)
    assert_equal 1, ethan.inactive_listings.size
  end
  
  def test_default_times
    owner = User.new
    assert_equal 9,owner.call_me_start_time
    assert_equal 17,owner.call_me_stop_time
    assert_equal 8,owner.text_me_start_time
    assert_equal 21,owner.text_me_stop_time
  end
  
  def test_invalid_times
    ethan = users(:ethan)
    assert ethan.valid?
    ethan.call_me_start_time = 7
    assert ethan.valid?
    ethan.call_me_start_time = 0
    assert !ethan.valid?
    ethan.call_me_start_time = 24 
    assert ethan.valid?
    ethan.call_me_start_time = 25
    assert !ethan.valid?
  end
  
  def test_edge_case_with_times
    ethan = users(:ethan)
    assert ethan.valid?
    ethan.call_me_start_time = 8
    ethan.call_me_stop_time = 8
    ethan.text_me_start_time = 8
    ethan.text_me_stop_time = 8
    assert ethan.valid?
  end
  
  def test_bad_phone_number
    ethan = users(:ethan)
    ethan.phone = "1 (573) 489-5632"
    assert !ethan.valid?
    ethan.phone = "1234567890"
    assert !ethan.valid?
    ethan.phone = "123456789"
    assert !ethan.valid?
    ethan.phone = "12345678901"
    assert ethan.valid?
    ethan.phone = "15732395840"
    assert ethan.valid?
  end
  
  def test_retrieve_by_phone_number
    ethan = users(:ethan)
    x = User.find_by_full_number("#{ethan.phone}")
    assert_equal ethan.id,x.id
  end
  
  def test_owner_reply_gets_sent_to_owner_trip_method
    User.any_instance.stubs(:send_sms)
    trip = Trip.new
    trip.expects(:process_owner_response).times(1).returns(nil)
    trip.expects(:process_renter_response).times(0).returns(nil)
    Message.any_instance.stubs(:trip).returns(trip)
    ethan = users(:ethan)
    ethan.send_threaded_message(1,"Some Message","OWNER")
    assert ethan.is_waiting_on_reply?
    ethan.process_reply("Some Reply")
    assert !ethan.is_waiting_on_reply?
  end
  
  def test_renter_reply_gets_sent_to_renter_trip_method
    User.any_instance.stubs(:send_sms)
    trip = Trip.new
    trip.expects(:process_owner_response).times(0).returns(nil)
    trip.expects(:process_renter_response).times(1).returns(nil)
    Message.any_instance.stubs(:trip).returns(trip)
    ethan = users(:ethan)
    ethan.send_threaded_message(1,"Some Message","RENTER")
    assert ethan.is_waiting_on_reply?
    ethan.process_reply("Some Reply")
    assert !ethan.is_waiting_on_reply?
  end

end
