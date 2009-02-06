require File.dirname(__FILE__) + '/../test_helper'
require 'mocha'

class MapItemTest < ActiveSupport::TestCase
  def test_invalid_nil_category
    md = map_items(:mickey_ds)
    assert md.valid?
    md.category = nil
    assert !md.valid?
  end
  
  def test_invalid_category
    md = map_items(:mickey_ds)
    assert md.valid?
    md.category = "GARBAGE"
    assert !md.valid?
  end
  
  def test_invalid_address
    locations = [stub(:precision => "city")]
    Yahoo::Geocode.any_instance.stubs(:locate).returns(locations)
    md = map_items(:mickey_ds)
    md.lat = nil
    assert !md.valid?
    assert_equal 1,md.errors.size
    assert_equal "Could not find coordinates for this address, or any similar addresses.  Please verify address.",md.errors.on_base
  end
  
  def test_load_geocodes
    locations = [stub(:precision => "address",:latitude=>38.89005,:longitude=>(-1 * 92.30648))]
    Yahoo::Geocode.any_instance.stubs(:locate).returns(locations)
    md = map_items(:mickey_ds)
    assert md.valid?
    assert_equal 38.89005,md.lat
    assert_equal((-(92.30648)),md.long)
  end  
  
  def test_multiple_geocode_results
    result1 = stub("res1",:address=>"111 smiley way")
    result2 = stub("res2",:address=>"111 smaliy way")
    Yahoo::Geocode.any_instance.stubs(:locate).returns([result1,result2]);
    md = map_items(:mickey_ds)
    assert !md.valid?
    assert_equal "Could not find coordinates for this address.  Please use one of the following addresses: <br/><b>111 smiley way</b> <br/><b>111 smaliy way</b> <br/>", md.errors.full_messages[0]
  end
  
  def test_invalid_nil_code
    md = map_items(:mickey_ds)
    assert md.valid?
    md.code = nil
    assert !md.valid?
  end
  
  def test_invalid_cross_category_code
    md = map_items(:mickey_ds)
    assert md.valid?
    md.code = md.code + 100
    assert !md.valid?
  end
  
  def test_default_flag_values
    mi = MapItem.new
    assert !mi.has_reservations
    assert !mi.can_order_online
    assert !mi.can_buy_tickets
    assert !mi.has_discount_coupon
    assert !mi.has_map
    assert !mi.verified
  end
  
  def test_category_from_code
    assert_equal "FOOD",MapItem.category_from_code(201)
    assert_equal "SHOPPING",MapItem.category_from_code(501)
  end
end
