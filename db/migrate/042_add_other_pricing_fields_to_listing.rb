class AddOtherPricingFieldsToListing < ActiveRecord::Migration
  def self.up
    add_column :listings,:min_bid,:integer
    add_column :listings,:default_indicated_price,:integer
  end

  def self.down
    remove_column :listings,:min_bid
    remove_column :listings,:default_indicated_price
  end
end
