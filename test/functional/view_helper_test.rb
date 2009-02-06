require File.dirname(__FILE__) + '/../test_helper'

class HelperTest < Test::Unit::TestCase
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  include ApplicationHelper
  include TripHelper

end