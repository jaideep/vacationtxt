class LoseOldFieldsFromListings < ActiveRecord::Migration
  def self.up
    remove_column :listing_units,:single_sleeper_count
    remove_column :listing_units,:double_sleeper_count
  end

  def self.down
    add_column :listing_units,:single_sleeper_count,:integer
    add_column :listing_units,:double_sleeper_count,:integer
  end
end
