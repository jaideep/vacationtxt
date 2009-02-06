require File.dirname(__FILE__) + '/../test_helper'

class VacationLinkTimeTest < ActiveSupport::TestCase
  def test_thirty_one_day_month
    assert_equal 31,VacationLinkTime.getDaysInMonth(2008,1)
  end
  
  def test_thirty_day_month
    assert_equal 30,VacationLinkTime.getDaysInMonth(2008,4)
  end
  
  def test_february
    assert_equal 28,VacationLinkTime.getDaysInMonth(2007,2)
  end
  
  def test_leap_february
    assert_equal 29,VacationLinkTime.getDaysInMonth(2008,2)
  end
  
  def test_fake_leap_february
    assert_equal 28,VacationLinkTime.getDaysInMonth(2000,2)
  end
end