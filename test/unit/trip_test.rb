require 'test_helper'
require 'mocha'

class TripTest < ActiveSupport::TestCase
  def test_destroying_a_picked_trip_doesnt_cancel
    trip = build_new_trip
    trip.status = "PICKED"
    trip.save!
    trip.expects(:cancel!).times(0)
    trip.destroy
  end
  
  def test_destroying_an_unavailable_trip_doesnt_cancel
    trip = build_new_trip
    trip.status = "UNAVAILABLE"
    trip.save!
    trip.expects(:cancel!).times(0)
    trip.destroy
  end
  
  def test_destroying_an_available_trip_doesnt_cancel
    trip = build_new_trip
    trip.status = "AVAILABLE"
    trip.save!
    trip.expects(:cancel!).times(0)
    trip.destroy
  end
  
  def test_destroying_a_counteroffer_trip_doesnt_cancel
    trip = build_new_trip
    trip.status = "COUNTEROFFER"
    trip.save!
    trip.expects(:cancel!).times(0)
    trip.destroy
  end
  
  def test_destroying_a_nonreservable_trip_doesnt_cancel
    trip = build_new_trip
    trip.status = "NOT_RESERVABLE"
    trip.save!
    trip.expects(:cancel!).times(0)
    trip.destroy
  end
  
  def test_destroying_a_picked_trip_doesnt_cancel
    trip = build_new_trip
    trip.status = "PICKED"
    trip.save!
    trip.expects(:cancel!).times(0)
    trip.destroy
  end
  
  def test_destroying_a_queried_trip_runs_cancel
    trip = build_new_trip
    trip.status = "QUERIED"
    trip.save!
    trip.expects(:cancel!).times(1)
    trip.destroy
  end
  
  def test_destroying_a_booked_trip_runs_cancel
    trip = build_new_trip
    trip.status = "BOOKED"
    trip.save!
    trip.expects(:cancel!).times(1)
    trip.destroy
  end
  
  def test_trip_with_listing_category_and_listing_id_is_valid
    trip = build_new_trip
    assert trip.valid?
    trip.category = "LISTING"
    trip.listing_unit_id = 1
    assert trip.valid?
  end
  
  def test_trip_with_listing_category_and_no_listing_id_is_not_valid
    trip = build_new_trip
    assert trip.valid?
    trip.category = "LISTING"
    trip.listing_unit_id = nil
    assert !trip.valid?
  end
  
  def test_trip_with_discount_category_and_discount_id_is_valid
    trip = build_new_trip
    assert trip.valid?
    trip.category = "DISCOUNT"
    trip.discount_id = 1
    assert trip.valid?
  end
  
  def test_trip_with_discount_category_and_no_dicount_id_is_not_valid
    trip = build_new_trip
    assert trip.valid?
    trip.category = "DISCOUNT"
    trip.discount_id = nil
    assert !trip.valid?
  end
  
  def test_trip_with_map_item_category_and_map_item_id_is_valid
    trip = build_new_trip
    assert trip.valid?
    trip.category = "MAP_ITEM"
    trip.map_item_id = 1
    assert trip.valid?
  end

  def test_trip_with_map_item_category_and_no_map_item_id_is_not_valid
    trip = build_new_trip
    assert trip.valid?
    trip.category = "MAP_ITEM"
    trip.map_item_id = nil
    assert !trip.valid?
  end
  
  def test_price_when_up_for_bid_is_trip_bid
    trip = build_new_trip
    trip.expects(:up_for_bid?).returns(true)
    trip.bid = 1313
    assert_equal 1313,trip.price
  end
  
  def test_price_when_not_bid_is_item_price
    trip = build_new_trip
    trip.expects(:up_for_bid?).returns(false)
    trip.bid = 1313
    assert_equal trip.item.price,trip.price
  end
  ['NOT_RESERVABLE','PICKED','QUERIED','AVAILABLE','UNAVAILABLE','COUNTEROFFER','BOOKED']
  def test_not_reservable_trip_is_not_actionable
    trip = build_new_trip
    trip.status = "NOT_RESERVABLE"
    assert !trip.actionable?
  end
  
  def test_picked_trip_is_actionable
    trip = build_new_trip
    trip.status = "PICKED"
    assert trip.actionable?
  end
  
  def test_queried_trip_is_not_actionable
    trip = build_new_trip
    trip.status = "QUERIED"
    assert !trip.actionable?
  end
  
  def test_available_trip_is_actionable
    trip = build_new_trip
    trip.status = "AVAILABLE"
    assert trip.actionable?
  end
  
  def test_unavailable_trip_is_actionable
    trip = build_new_trip
    trip.status = "UNAVAILABLE"
    assert trip.actionable?
  end
  
  def test_counteroffer_trip_is_actionable
    trip = build_new_trip
    trip.status = "COUNTEROFFER"
    assert trip.actionable?
  end
  
  def test_booked_trip_is_not_actionable
    trip = build_new_trip
    trip.status = "BOOKED"
    assert !trip.actionable?
  end
  
  def test_threading_bug
    User.any_instance.stubs(:send_sms)
    property_owner = User.new(:password=>"pass", :name=>"name", :email=>"hello@world.com", :phone=>"15734460107", :street_address=>"123 Some Street", :city=>"Columbia", :state=>"MO", :zip=>"65203")
    property_owner.save!
    assert_equal 0,property_owner.messages.size
    assert_nil property_owner.message_waiting_id
    assert !property_owner.is_waiting_on_reply?
    
    listing = Listing.new(:region=>Listing::REGIONS[0],:lat=>31.1,:long=>31.1,:user_id=>property_owner.id, :street_address=>"1504 W Lexington Circle", :city=>"Columbia", :state=>"MO", :zip=>"65203", :description=>"Description", :strong_name=>"primary residence", :pricing_type=>"FIXED")
    listing.save!
    unit = ListingUnit.new(:price=>200,:listing_id=>listing.id,:strong_name=>"unit_1")
    unit.save!
    
    
    renter = User.new(:password=>"pass", :name=>"name", :email=>"world@hello.com", :phone=>"15734451223", :street_address=>"123 Some Street", :city=>"Columbia", :state=>"MO", :zip=>"65203")
    renter.save!
    renter.add_listing_to_trip(unit)
    assert_equal 1,renter.trips.size
    
    trip = renter.trips[0]
    trip.check_availability
    assert_equal "QUERIED",trip.status 
    
    property_owner = User.find(property_owner.id) 
    assert_equal 1,property_owner.messages.size
    assert property_owner.is_waiting_on_reply?
    assert_equal property_owner.messages[0].id,property_owner.message_waiting_id
    
    trip.destroy
    assert_equal "PICKED",trip.status
    property_owner = User.find(property_owner.id) 
    assert !property_owner.is_waiting_on_reply?
  end
  
  def test_fixed_available_owner_response_message
    user = users(:ethan)
    trip = Trip.new(:status=>"QUERIED",:category=>"LISTING",:listing_unit_id=>1,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    trip.expects(:send_renter_sms).with("Property '#{trip.item.name}' is available, text back 'Y' to confirm or confirm on vacationstxt.com")
    trip.process_owner_response "Y"
  end
  
  def test_fixed_unavailable_owner_response_message
    user = users(:ethan)
    trip = Trip.new(:status=>"QUERIED",:category=>"LISTING",:listing_unit_id=>1,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    trip.expects(:send_renter_sms).with("Property '#{trip.item.name}' is unavailable")
    trip.process_owner_response "N"
  end
  
  def test_fixed_counteroffer_owner_response_message
    user = users(:ethan)
    trip = Trip.new(:status=>"QUERIED",:category=>"LISTING",:listing_unit_id=>1,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    trip.expects(:send_renter_sms).times(0)
    begin
      trip.process_owner_response "300"
      assert false
    rescue Exception=>e
      assert_equal "Improper SMS Response",e.message
    end 
  end
  
  def test_fixed_nonsense_owner_response_message
    user = users(:ethan)
    trip = Trip.new(:status=>"QUERIED",:category=>"LISTING",:listing_unit_id=>1,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    trip.expects(:send_renter_sms).times(0)
    begin
      trip.process_owner_response "O"
      assert false
    rescue Exception=>e
      assert_equal "Improper SMS Response",e.message
    end
  end
  
  def test_bid_available_owner_response_message
    user = users(:ethan)
    trip = Trip.new(:status=>"QUERIED",:category=>"LISTING",:listing_unit_id=>4,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    trip.expects(:send_renter_sms).with("owner of '#{trip.item.name}' has accepted the bid, text back 'Y' to confirm or confirm on vacationstxt.com")
    trip.process_owner_response "Y"
  end
  
  def test_bid_unavailable_owner_response_message
    user = users(:ethan)
    trip = Trip.new(:status=>"QUERIED",:category=>"LISTING",:listing_unit_id=>4,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    trip.expects(:send_renter_sms).with("owner of '#{trip.item.name}' has declined the bid")
    trip.process_owner_response "N"
  end
  
  def test_bid_counteroffer_owner_response_message
    user = users(:ethan)
    trip = Trip.new(:status=>"QUERIED",:category=>"LISTING",:listing_unit_id=>4,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    trip.expects(:send_renter_sms).with("owner of '#{trip.item.name}' has offered $300 per night; text back 'Y', 'N', or counteroffer (or respond on vacationstxt.com)")
    trip.process_owner_response "300"
  end

  def test_bid_nonsense_owner_response_message
    user = users(:ethan)
    trip = Trip.new(:status=>"QUERIED",:category=>"LISTING",:listing_unit_id=>4,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    trip.expects(:send_renter_sms).times(0)
    begin
      trip.process_owner_response "O"
      assert false
    rescue Exception=>e
      assert_equal "Improper SMS Response",e.message
    end
  end
  
  def test_sending_renter_threaded_message
    User.any_instance.stubs(:send_sms)
    user = users(:ethan)
    trip = Trip.new(:status=>"QUERIED",:category=>"LISTING",:listing_unit_id=>4,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    assert !user.is_waiting_on_reply?
    trip.send_renter_sms("Some Message")
    user = User.find(user.id)
    assert user.is_waiting_on_reply?
  end
  
  def test_renter_confirms_fixed_price
    User.any_instance.stubs(:send_sms)
    Trip.any_instance.stubs(:send_sms)
    user = users(:ethan)
    trip = Trip.new(:status=>"AVAILABLE",:category=>"LISTING",:listing_unit_id=>1,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.process_renter_response("Y")
    assert_equal "BOOKED",trip.status
  end
  
  def test_renter_confirms_bid
    User.any_instance.stubs(:send_sms)
    Trip.any_instance.stubs(:send_sms)
    user = users(:ethan)
    trip = Trip.new(:status=>"AVAILABLE",:category=>"LISTING",:listing_unit_id=>4,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.process_renter_response("Y")
    assert_equal "BOOKED",trip.status
  end
  
  def test_renter_confirms_counteroffer
    User.any_instance.stubs(:send_sms)
    Trip.any_instance.stubs(:send_sms)
    user = users(:ethan)
    trip = Trip.new(:status=>"COUNTEROFFER",:category=>"LISTING",:listing_unit_id=>4,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.process_renter_response("Y")
    assert_equal "BOOKED",trip.status
  end
  
  def test_renter_cancels_fixed_price
    User.any_instance.stubs(:send_sms)
    Trip.any_instance.stubs(:send_sms)
    user = users(:ethan)
    trip = Trip.new(:status=>"AVAILABLE",:category=>"LISTING",:listing_unit_id=>1,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    trip.process_renter_response("N")
    assert_nil Trip.find(:first,:conditions=>"id = #{trip.id}")
  end
  
  def test_renter_cancels_bid
    User.any_instance.stubs(:send_sms)
    Trip.any_instance.stubs(:send_sms)
    user = users(:ethan)
    trip = Trip.new(:status=>"AVAILABLE",:category=>"LISTING",:listing_unit_id=>4,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    trip.process_renter_response("N")
    assert_nil Trip.find(:first,:conditions=>"id = #{trip.id}")
  end
  
  def test_renter_counteroffers
    User.any_instance.stubs(:send_sms)
    Trip.any_instance.stubs(:send_sms)
    user = users(:ethan)
    trip = Trip.new(:status=>"COUNTEROFFER",:category=>"LISTING",:listing_unit_id=>4,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    trip.process_renter_response("250")
    assert_equal "QUERIED",trip.status
    assert_equal 250,trip.bid
    user = User.find(user.id)
    assert_equal 1,user.messages.size
  end
  
  def test_booking_trip_clears_renter_message_out_of_queue
    User.any_instance.stubs(:send_sms)
    Trip.any_instance.stubs(:send_sms)
    user = users(:ethan)
    trip = Trip.new(:status=>"AVAILABLE",:category=>"LISTING",:listing_unit_id=>6,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    user.send_threaded_message(trip.id,"It's available","RENTER")
    assert user.is_waiting_on_reply?
    trip.book!
    user = User.find(user.id)
    assert !user.is_waiting_on_reply?
  end
  
  def test_removing_trip_clears_renter_message_out_of_queue
    User.any_instance.stubs(:send_sms)
    Trip.any_instance.stubs(:send_sms)
    user = users(:ethan)
    trip = Trip.new(:status=>"AVAILABLE",:category=>"LISTING",:listing_unit_id=>6,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    user.send_threaded_message(trip.id,"It's available","RENTER")
    assert user.is_waiting_on_reply?
    trip.destroy
    user = User.find(user.id)
    assert !user.is_waiting_on_reply?
  end
  
  def test_counteroffering_clears_renter_message_out_of_queue
    User.any_instance.stubs(:send_sms)
    Trip.any_instance.stubs(:send_sms)
    user = users(:ethan)
    trip = Trip.new(:status=>"COUNTEROFFER",:category=>"LISTING",:listing_unit_id=>5,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    
    user.send_threaded_message(trip.id,"It's available","RENTER")
    user = User.find(user.id)
    assert_equal 1,user.messages.size
    user_msg = user.messages[0]
    assert_equal user.message_waiting_id,user_msg.id
    assert user.is_waiting_on_reply?
    assert_equal trip.id,user_msg.trip_id
    
    trip.check_availability
    user = User.find(user.id)
    assert !user.is_waiting_on_reply?
  end
  
  def test_booking_sends_two_messages
    renter = users(:oliver)
    owner = users(:ethan)
    trip = Trip.new(:status=>"COUNTEROFFER",:category=>"LISTING",:listing_unit_id=>5,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>renter.id)
    trip.expects(:send_sms).times(2)
    trip.save!
    trip.book!
  end
  
  def test_item_gets_calendar_opened_upon_cancellation_of_booked_trip
    item = Object.new
    trip = Trip.new(:status=>"BOOKED",:category=>"LISTING",:listing_unit_id=>5,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>1)
    trip.save!
    item.expects(:unbook!).with(trip.start,trip.stop).returns(true)
    item.expects(:cancel_trip).returns(true)
    item.expects(:name).returns("name")
    trip.stubs(:item).returns(item)
    trip.cancel!
  end
  
  def test_item_DOES_NOT_get_calendar_opened_upon_cancellation_of_nonbooked_trip
    item = Object.new
    trip = Trip.new(:status=>"AVAILABLE",:category=>"LISTING",:listing_unit_id=>5,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>1)
    trip.save!
    item.expects(:unbook!).times(0)
    item.expects(:cancel_trip).returns(true)
    item.expects(:name).returns("name")
    trip.stubs(:item).returns(item)
    trip.cancel!
  end
  
  def test_no_checking_availability_when_message_is_already_out
    User.any_instance.stubs(:send_sms)
    user = users(:ethan)
    trip = Trip.new(:status=>"QUERIED",:category=>"LISTING",:listing_unit_id=>4,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    trip.expects(:item).times(0)
    trip.expects(:save!).times(0)
    trip.expects(:save).times(0)
    trip.check_availability
  end
  
private
  def build_new_trip
    t = Trip.new(:category=>"LISTING",:listing_unit_id=>1,:status=>"NOT_RESERVABLE",:user_id=>1)
    t.save!
    return t
  end
end
