require 'test_helper'

class DiscountsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:discounts)
  end
end
