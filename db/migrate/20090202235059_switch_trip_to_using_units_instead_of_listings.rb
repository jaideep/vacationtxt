class SwitchTripToUsingUnitsInsteadOfListings < ActiveRecord::Migration
  def self.up
    Trip.delete_all
    add_column :trips,:listing_unit_id,:integer
    remove_column :trips,:listing_id
  end

  def self.down
    Trip.delete_all
    remove_column :trips,:listing_unit_id
    add_column :trips,:listing_id,:integer
  end
end
