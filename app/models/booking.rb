class Booking < ActiveRecord::Base
  validates_presence_of :check_in,:check_out
end
