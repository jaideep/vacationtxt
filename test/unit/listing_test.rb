require File.dirname(__FILE__) + '/../test_helper'
require 'mocha'

class ListingTest < ActiveSupport::TestCase
  
  def test_validate_required_attributes
    listing = Listing.new    
    assert !listing.valid?
    assert listing.errors.invalid?(:street_address)
    assert listing.errors.invalid?(:city)
    assert listing.errors.invalid?(:state)
    assert listing.errors.invalid?(:zip)
    assert listing.errors.invalid?(:user_id)
    assert listing.errors.invalid?(:description)
  end
  
  def test_valid_listing
    condo = listings(:ethans_condo)
    assert condo.valid?
  end
  
  def test_invalid_address
    locations = [stub(:precision => "city")]
    Yahoo::Geocode.any_instance.stubs(:locate).returns(locations)
    cabin = listings(:ethans_cabin)
    cabin.lat = nil
    assert !cabin.valid?
    assert_equal 1,cabin.errors.size
    assert_equal "Could not find coordinates for this address, or any similar addresses.  Please verify address.",cabin.errors.on_base
  end
  
  def test_attached_owner
    cabin = listings(:ethans_cabin)
    appartment = listings(:ethans_appartment)
    condo = listings(:ethans_condo)
    ethan = users(:ethan)
    assert_equal ethan,cabin.user
    assert_equal ethan,appartment.user
    assert_equal ethan,condo.user
  end
  
  def test_load_geocodes
    locations = [stub(:precision => "address",:latitude=>38.89005,:longitude=>(-1 * 92.30648))]
    Yahoo::Geocode.any_instance.stubs(:locate).returns(locations)
    house = build_valid_new_house
    assert house.valid?
    assert_equal 38.89005,house.lat
    assert_equal((-(92.30648)),house.long)
  end
  
  def test_multiple_geocode_results
    result1 = stub("res1",:address=>"111 smiley way")
    result2 = stub("res2",:address=>"111 smaliy way")
    Yahoo::Geocode.any_instance.stubs(:locate).returns([result1,result2]);
    house = build_valid_new_house
    assert !house.valid?
    assert_equal "Could not find coordinates for this address.  Please use one of the following addresses: <br/><b>111 smiley way</b> <br/><b>111 smaliy way</b> <br/>", house.errors.full_messages[0]
  end
  
  def test_belongs_to_true
    condo = listings(:ethans_condo)
    ethan = users(:ethan)
    assert condo.belongs_to(ethan)
  end
  
  def test_belongs_to_false
    condo = listings(:ethans_condo)
    oliver = users(:oliver)
    assert !condo.belongs_to(oliver)
  end
  
  def test_gmap_html
    condo = listings(:ethans_condo)    
    assert_equal(condo.description, condo.gmap_html)
  end
  
  def test_strong_name
    condo = listings(:ethans_condo)
    assert condo.valid?
    condo.strong_name = nil
    assert !condo.valid?
    condo.strong_name = listings(:ethans_cabin).strong_name
    assert !condo.valid?
    condo.strong_name = "Bal Shaire"
    assert condo.valid?
  end
  
  def test_file_data_assignment
    file_data = stub("file_stub",:original_filename=>"olly.olly.oxen.free.txt")
    condo = listings(:ethans_condo)
    condo.file_data = file_data
    assert_equal "txt", condo.extension
  end
  
  def test_file_paths_for_pictures
    file_data = stub("file_stub",:original_filename=>"olly.olly.oxen.free.txt")
    condo = listings(:ethans_condo)
    condo.file_data = file_data
    id = condo.id
    assert_equal "public/pics/#{id}-thumb.txt", condo.thumbnail_path
    assert_equal "/pics/#{id}-thumb.txt", condo.thumbnail_url
    assert_equal "public/pics/#{id}-full.txt", condo.path
    assert_equal "/pics/#{id}-full.txt", condo.url
  end
  
  def test_pricing_options
    assert_equal ['FIXED','BID'],Listing.pricing_types
  end
  
  def test_default_pricing_option
    l = Listing.new
    assert_nil l.pricing_type
  end
  
  def test_invalid_nil_pricing_option
    condo = listings(:ethans_condo)
    assert condo.valid?
    condo.pricing_type = nil
    assert !condo.valid?
  end
  
  def test_invalid_pricing_option
    condo = listings(:ethans_condo)
    assert condo.valid?
    condo.pricing_type = "GARBAGE"
    assert !condo.valid?
  end
  
private
  def build_valid_new_house
    house = Listing.new
    house.street_address = '2275 E Bearfield Subdivision'
    house.city = 'Columbia'
    house.state = 'MO'
    house.zip = '65201'
    house.user_id = 1
    house.description = "Large house by the lakeside"
    house.strong_name = "Geocoded House"
    house.pricing_type = "FIXED"
    house.region = Listing::REGIONS[0]
    
    house_unit = ListingUnit.new(:bed_count=>1,:max_people=>2,:price=>150,:strong_name=>"Unit 1",:listing_id=>house.id )
    house.listing_units << house_unit
    return house
  end
end
