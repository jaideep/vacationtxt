require 'test_helper'

class DiscountTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_file_data_assignment
    file_data = stub("file_stub",:original_filename=>"olly.olly.oxen.free.txt")
    discount = discounts(:one)
    discount.file_data = file_data
    assert_equal "txt", discount.extension
  end
  
  def test_file_paths_for_pictures
    file_data = stub("file_stub",:original_filename=>"olly.olly.oxen.free.txt")
    discount = discounts(:one)
    discount.file_data = file_data
    id = discount.id
    assert_equal "public/pics/discounts/#{id}-thumb.txt", discount.thumbnail_path
    assert_equal "/pics/discounts/#{id}-thumb.txt", discount.thumbnail_url
    assert_equal "public/pics/discounts/#{id}-full.txt", discount.path
    assert_equal "/pics/discounts/#{id}-full.txt", discount.url
  end
  

end
