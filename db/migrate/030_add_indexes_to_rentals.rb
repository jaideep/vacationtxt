class AddIndexesToRentals < ActiveRecord::Migration
  def self.up
    add_index :rentals, "customer_id", :unique=>false
    add_index :rentals, "listing_id", :unique=>false
  end

  def self.down
    remove_index :rentals, "customer_id"
    remove_index :rentals, "listing_id"
  end
end
