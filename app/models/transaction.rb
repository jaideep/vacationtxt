class Transaction < ActiveRecord::Base
  validates_presence_of :renter_id, :owner_id, :listing_unit_id, :price, :start, :stop, :timestamp
  validates_numericality_of :renter_id, :owner_id, :listing_unit_id, :price
end
