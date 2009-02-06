class IndexListingUnits < ActiveRecord::Migration
  def self.up
    add_index :listing_units,'listing_id'
  end

  def self.down
    remove_index :listing_units,'listing_id'
  end
end
