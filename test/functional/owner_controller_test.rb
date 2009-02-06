require File.dirname(__FILE__) + '/../test_helper'
require 'yahoo/geocode'
require 'mocha'

class OwnerControllerTest < ActionController::TestCase
  
  def test_register
    get :register
    assert_response :success
  end
  
  def test_activate_registration_as_get_request
    test_action_that_should_only_accept_post :activate_registration
  end
  
  def test_activate_registration_with_invalid_form_data
    post :activate_registration, {:owner =>{:name => "Ethan Vizitei"}}
    assert_response :success
    assert_template "owner/register"
  end
  
  def test_activate_registration_with_valid_form_data
    init_count = User.count
    post :activate_registration, {:owner =>{:name => "Ethan Vizitei",
                                            :email=>"e@something.com",
                                            :password=>"password",
                                            :phone=>"11234567890",
                                            :street_address =>"123 clark lane",
                                            :city=>"Columbia",
                                            :state=>"MO",
                                            :zip=>"65201",
                                            :call_me_start_time=>9,
                                            :call_me_stop_time=>20,
                                            :text_me_start_time=>1,
                                            :text_me_stop_time=>24}}
    assert_redirected_to :action => :account
    assert_equal (init_count + 1), User.count
  end
  
  def test_login
    get :login
    assert_response :success
  end
  
  def test_logout
    get :logout, {},{:user_id => 1}
    assert_redirected_to :action => :welcome,:controller=>:main
    assert_nil session[:user_id]
  end
  
  def test_activate_login_with_get_request
    test_action_that_should_only_accept_post :activate_login
  end
  
  def test_activate_login_with_bad_credentials
    post :activate_login, {:username => "NON_NAME",:password => "NON_PASSWORD"}
    assert_response :success
    assert_template 'owner/login'
    assert_equal "Email or Password is Invalid!", flash[:notice]
    assert_nil session[:user_id]
    assert_nil assigns[:owner]
  end
  
  def test_activate_login_with_valid_credentials
    ethan = users(:ethan)
    post :activate_login, {:username => ethan.email,:password => ethan.password}
    assert_equal ethan.id,session[:user_id]
    assert_equal ethan,assigns(:owner)
  end
  
  def test_account_without_login    
    test_action_without_login :account,"see your account"
  end
  
  def test_account_when_logged_in   
    ethan = users(:ethan)
    get :account, {}, {:user_id => ethan.id}
    assert_response :success
    assert_equal ethan, assigns(:owner)
  end
  
  def test_see_listings_not_logged_in
    test_action_without_login :see_listings,"see your listings"
  end
  
  def test_see_listings_logged_in
    ethan = users(:ethan)
    get :see_listings, {}, {:user_id => ethan.id}
    assert_response :success
    assert_equal ethan, assigns(:owner)
  end
  
  def test_add_listing_without_login    
    test_action_without_login :add_listing, "add a listing"
  end
  
  def test_add_listing_with_login    
    ethan = users(:ethan)
    get :add_listing, {}, {:user_id=>ethan.id}
    assert_response :success
    assert_not_nil assigns(:listing)
  end
  
  def test_exec_add_listing_without_login    
    test_action_without_login :exec_add_listing,"add a listing"
  end
  
  def test_exec_add_listing_with_get_request
    test_action_that_should_only_accept_post :exec_add_listing
  end
  
  def test_exec_add_listing_with_invalid_form_data
    ethan = users(:ethan)
    post :exec_add_listing, {:listing =>{:street_address => "555 some way"}}, {:user_id => ethan.id}
    assert_response :success
    assert_template "owner/add_listing"
  end
  
  def test_delete_listing_without_login   
    test_action_without_login :delete_listing,"delete a listing"
  end
  
  def test_delete_listing_with_get_request    
    test_action_that_should_only_accept_post :delete_listing
  end
  
  def test_delete_listing_without_param_specified
    ethan = users(:ethan)
    post :delete_listing, {}, {:user_id=>ethan.id}
    assert_redirected_to :action => :see_listings
    assert_equal "You must specify a listing to delete", flash[:notice]
  end
  
  def test_attempt_delete_another_persons_listing
    oliver = users(:oliver)
    condo = listings(:ethans_condo)
    post :delete_listing, {:id=>condo.id}, {:user_id=>oliver.id}
    assert_redirected_to :action => :see_listings
    assert_equal "You cannot delete a listing that you do not own", flash[:notice]
  end
  
  def test_valid_delete_listing
    init_count = Listing.count
    ethan = users(:ethan)
    condo = listings(:ethans_condo)
    post :delete_listing, {:id=>condo.id}, {:user_id=>ethan.id}
    assert_redirected_to :action => :see_listings
    assert_equal "listing deleted.", flash[:notice]
    assert_equal init_count - 1, Listing.count
  end
  
  def test_preferences_without_login    
    test_action_without_login :preferences, "edit preferences"
  end
  
  def test_preferences_when_logged_in   
    ethan = users(:ethan)
    get :preferences, {}, {:user_id => ethan.id}
    assert_response :success
    assert_equal ethan, assigns(:owner)
  end
  
  def test_save_preferences_without_login
    test_action_without_login :save_preferences, "edit preferences"
  end
  
  def test_save_preferences_as_get_request
    test_action_that_should_only_accept_post :save_preferences    
  end
  
  def test_save_preferences_with_invalid_form_data
    ethan = users(:ethan)
    post :save_preferences, {:owner =>{:call_me_start_time => -2}},{:user_id=>ethan.id}
    assert_response :success
    assert_template "owner/preferences"
  end
  
  def test_save_preferences_with_valid_form_data
    ethan = users(:ethan)
    assert ethan.valid?
    post :save_preferences, {:owner =>{:call_me_start_time=>8,:call_me_stop_time=>8,:text_me_start_time=>8,:text_me_stop_time=>8}},{:user_id=>ethan.id}
    assert_redirected_to :action => :account
    assert_equal "Changes Saved!",flash[:notice]  
    ethan = User.find(ethan.id)
    assert_equal 8,ethan.call_me_start_time
    assert_equal 8,ethan.call_me_stop_time
    assert_equal 8,ethan.text_me_start_time
    assert_equal 8,ethan.text_me_stop_time
  end
  
  def test_edit_listing_without_login
    test_action_without_login(:edit_listing,"edit listings")
  end
  
  def test_edit_listing_without_param_specified
    ethan = users(:ethan)
    get :edit_listing, {}, {:user_id=>ethan.id}
    assert_redirected_to :action => :see_listings
    assert_equal "You must specify a listing to edit", flash[:notice]
  end
  
  def test_attempt_edit_another_persons_listing
    oliver = users(:oliver)
    condo = listings(:ethans_condo)
    post :edit_listing, {:id=>condo.id}, {:user_id=>oliver.id}
    assert_redirected_to :action => :see_listings
    assert_equal "You cannot edit a listing that you do not own", flash[:notice]
  end
  
  def test_valid_edit_listing
    ethan = users(:ethan)
    condo = listings(:ethans_condo)
    post :edit_listing, {:id=>condo.id}, {:user_id=>ethan.id}
    assert_response :success
    assert_equal nil, flash[:notice]
  end
  
  def test_save_listing_changes_without_login   
    test_action_without_login :save_listing_changes,"edit listings"
  end
  
  def test_save_listing_changes_with_get_request    
    test_action_that_should_only_accept_post :save_listing_changes
  end
  
  def test_save_listing_without_param_specified
    ethan = users(:ethan)
    post :save_listing_changes, {}, {:user_id=>ethan.id}
    assert_redirected_to :action => :see_listings
    assert_equal "You must specify a listing to edit", flash[:notice]
  end
  
  def test_attempt_save_changes_to_another_persons_listing
    oliver = users(:oliver)
    condo = listings(:ethans_condo)
    post :save_listing_changes, {:id=>condo.id}, {:user_id=>oliver.id}
    assert_redirected_to :action => :see_listings
    assert_equal "You cannot edit a listing that you do not own", flash[:notice]
  end
  
  def test_valid_save_listing_changes_without_new_picture
    ethan = users(:ethan)
    condo = listings(:ethans_condo)
    post :save_listing_changes, {:id=>condo.id,:listing =>{:street_address => "4303 S. Providence Road",:city => "Columbia",:state => "MO", :zip=>"65203",:description=>"freakin highschool",:file_data=>""}}, {:user_id=>ethan.id}
    assert_redirected_to :action => :see_listings
    db_condo = Listing.find(condo.id)
    assert_equal "changes to listing saved", flash[:notice]
  end
  
  def test_edit_account_without_login    
    test_action_without_login :edit_account, "edit account details"
  end
  
  def test_edit_account_when_logged_in   
    ethan = users(:ethan)
    get :edit_account, {}, {:user_id => ethan.id}
    assert_response :success
    assert_equal ethan, assigns(:owner)
  end
  
  def test_save_account_changes_without_login
    test_action_without_login :save_account_changes, "edit account details"
  end
  
  def test_save_account_changes_as_get_request
    test_action_that_should_only_accept_post :save_account_changes    
  end
  
  def test_save_account_changes_with_invalid_form_data
    ethan = users(:ethan)
    post :save_account_changes, {:owner =>{:phone => "andeafe"}},{:user_id=>ethan.id}
    assert_response :success
    assert_template "owner/edit_account"
  end
  
private
  def test_action_without_login(action,message_stub)
    get action
    assert_redirected_to :action => :login
    assert_equal "you must be logged in to #{message_stub}", flash[:notice]
  end
  
  def test_action_that_should_only_accept_post(action)
    ethan = users(:ethan)
    get action,{},{:user_id => ethan.id}
    assert_redirected_to :action => :login
    assert_equal "Improper Action Taken.", flash[:notice]
  end
end
