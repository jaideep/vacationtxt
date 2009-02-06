require File.dirname(__FILE__) + '/../test_helper'
require 'mocha'

class CustomerControllerTest < ActionController::TestCase
  
  def test_register
    get :register
    assert_response :success
  end
  
  def test_activate_registration_as_get_request
    get :activate_registration
    assert_redirected_to :action => :login
  end
  
  def test_activate_registration_with_invalid_form_data
    post :activate_registration, {:post => {:customer =>{:name => "Julian Vizitei"}}}
    assert_response :success
    assert_template "customer/register"
  end
  
  
  def test_login
    get :login
    assert_response :success
  end
  
  def test_logout
    get :logout, {},{:user_id => 1}
    assert_redirected_to :action => :login
    assert_nil session[:user_id]
  end
  
  def test_activate_login_with_get_request
    get :activate_login, {}, {}
    assert_redirected_to :action => :login
    assert_nil session[:user_id]
    assert_nil assigns[:customer]    
  end
  
  def test_activate_login_with_bad_credentials
    post :activate_login, {:username => "NON_NAME",:password => "NON_PASSWORD"}
    assert_response :success
    assert_template 'customer/login'
    assert_equal "Email Address or Password is Invalid!", flash[:notice]
    assert_nil session[:user_id]
    assert_nil assigns[:customer]
  end
  
  def test_activate_login_with_valid_credentials
    charvel = users(:charvel)
    post :activate_login, {:username => charvel.email,:password => charvel.password}
    assert_equal charvel.id,session[:user_id]
    assert_equal charvel,assigns(:customer)
  end
  
  def test_see_rentals
    get :see_rentals
    assert_response :success
  end
  
  def test_view_listing_with_param
    condo = listings(:ethans_condo)
    get :view_listing, {:id=>condo.id},{}
    assert_response :success
    assert_equal condo,assigns(:listing)
  end
  
  def test_edit_account_without_login    
    test_action_without_login :edit_account, "edit account details"
  end
  
  def test_edit_account_when_logged_in   
    charvel = users(:charvel)
    get :edit_account, {}, {:user_id => charvel.id}
    assert_response :success
    assert_equal charvel, assigns(:customer)
  end
  
  def test_save_account_changes_without_login
    test_action_without_login :save_account_changes, "edit account details"
  end
  
  def test_save_account_changes_as_get_request
    test_action_that_should_only_accept_post :save_account_changes    
  end
  
  def test_save_account_changes_with_invalid_form_data
    charvel = users(:charvel)
    post :save_account_changes, {:customer =>{:phone => "andeafe"}},{:user_id=>charvel.id}
    assert_response :success
    assert_template "customer/edit_account"
  end  

  def test_preferences_without_login    
    test_action_without_login :preferences, "edit preferences"
  end
  
  def test_preferences_when_logged_in   
    charvel = users(:charvel)
    get :preferences, {}, {:user_id => charvel.id}
    assert_response :success
    assert_equal charvel, assigns(:customer)
  end
  
  def test_save_preferences_without_login
    test_action_without_login :save_preferences, "edit preferences"
  end
  
  def test_save_preferences_as_get_request
    test_action_that_should_only_accept_post :save_preferences    
  end
  
  def test_save_preferences_with_invalid_form_data
    charvel = users(:charvel)
    post :save_preferences, {:customer =>{:default_search_single_count => -2}},{:user_id=>charvel.id}
    assert_response :success
    assert_template "customer/preferences"
  end
  
  def test_save_preferences_with_valid_form_data
    charvel = users(:charvel)
    post :save_preferences, {:customer =>{:default_search_single_count=>2,:default_search_double_count=>2,:default_search_max_price=>200}},{:user_id=>charvel.id}
    assert_redirected_to :action => :account
    assert_equal "Changes Saved!",flash[:notice]  
    charvel = User.find(charvel.id)
    assert_equal 2,charvel.default_search_single_count
    assert_equal 2,charvel.default_search_double_count
    assert_equal 200,charvel.default_search_max_price
  end
private
  def test_action_without_login(action,message_stub)
    get action
    assert_redirected_to :action => :login
    assert_equal "you must be logged in to #{message_stub}", flash[:notice]
  end
  
  def test_action_that_should_only_accept_post(action)
    charvel = users(:charvel)
    get action,{},{:user_id => charvel.id}
    assert_redirected_to :action => :login
    assert_equal "Improper Action Taken.", flash[:notice]
  end
end
