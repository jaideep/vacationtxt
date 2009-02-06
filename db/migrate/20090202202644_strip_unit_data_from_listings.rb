class StripUnitDataFromListings < ActiveRecord::Migration
  def self.up
    remove_column :listings,:single_sleeper_count
    remove_column :listings,:double_sleeper_count
    remove_column :listings,:price
    remove_column :listings,:min_bid
    remove_column :listings,:default_indicated_price
  end

  def self.down
    add_column :listings,:single_sleeper_count,:integer
    add_column :listings,:double_sleeper_count,:integer
    add_column :listings,:price,:integer
    add_column :listings,:min_bid,:integer
    add_column :listings,:default_indicated_price,:integer
  end
end
