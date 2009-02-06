class Rental < ActiveRecord::Base
  belongs_to :user
  belongs_to :listing
  validates_presence_of :user_id, :listing_id, :price, :confirmed_date, :rental_date, :rental_date_end
end
