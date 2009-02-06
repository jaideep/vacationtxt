require File.dirname(__FILE__) + '/../test_helper'
require 'mocha'

class MainControllerTest < ActionController::TestCase
  
  def test_welcome_with_get
    get :welcome
    assert_response :success
  end
  
  def test_welcome_with_post_no_params
    post :welcome,{},{}
    assert_response :success
    assert_nil assigns(:search_results)
    assert_nil assigns(:customer)
  end
  
  def test_welcome_when_logged_in
    charvel = users(:charvel)
    post :welcome,{},{:user_id=>charvel.id}
    assert_equal charvel,assigns(:customer)
  end
  
  def test_search_with_no_params
    post :cached_map_search,{},{:map_search_parms=>{}}
    assert_equal "",@response.body
  end
  
  def test_search_with_non_inclusive_price_params
    post :cached_map_search,{}, {:map_context=>{:bed_count=>0,:max_people=>0,:max_price=>0}}
    assert_equal "[]",@response.body
  end
  
  def test_renter_counteroffer_doesnt_send_double_messages
    user = users(:ethan)
    
    assert !user.is_waiting_on_reply?
    trip = Trip.new(:status=>"COUNTEROFFER",:category=>"LISTING",:listing_unit_id=>4,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    trip.save!
    user.stubs(:send_sms)
    user.send_threaded_message(trip.id,"Owner countered...","RENTER")
    usr = User.find(user.id)
    assert_equal 1,usr.messages.size
    assert usr.is_waiting_on_reply?
    
    
    class << usr
      attr_accessor :count
      def inc
        @count += 1
      end
      
      def send_sms(number,message)
        @count ||= 0
        inc
      end
    end
    Listing.any_instance.stubs(:user).returns(usr)
    User.expects(:find_by_full_number).returns(usr)
    post :process_sms,{:sender=>user.full_number,:data=>"100"},{}
    user = User.find(user.id)
    assert_equal 1,user.messages.size
    assert user.is_waiting_on_reply?
    assert_equal 1,usr.count
  end
  
  def test_other_instance_of_doubling
    # user = users(:oliver)
    #     
    #     assert !user.is_waiting_on_reply?
    #     trip = Trip.new(:status=>"COUNTEROFFER",:category=>"LISTING",:listing_id=>4,:start=>DateTime.now,:stop=>(DateTime.now + 1.day),:user_id=>user.id)
    #     trip.save!
    #     user.stubs(:send_sms)
    #     user.send_threaded_message(trip.id,"Owner countered...","RENTER")
    #     usr = User.find(user.id)
    #     assert_equal 1,usr.messages.size
    #     assert usr.is_waiting_on_reply?
    #     
    #     post :process_sms,{:sender=>user.full_number,:data=>"100"},{}
    #     assert_equal 1,Listing.find(4).user.messages.size
  end
end
