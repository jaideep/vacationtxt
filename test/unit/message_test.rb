require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  def test_message_with_valid_role
    msg = Message.new(:trip_id=>1,:user_id=>1,:role=>"OWNER")
    assert msg.valid?
  end
  
  def test_message_with_invalid_role
    msg = Message.new(:trip_id=>1,:user_id=>1,:role=>"NONSENSE")
    assert !msg.valid?
  end
end
