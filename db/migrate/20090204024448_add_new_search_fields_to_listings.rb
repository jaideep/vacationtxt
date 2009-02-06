class AddNewSearchFieldsToListings < ActiveRecord::Migration
  def self.up
    add_column :listing_units,:bed_count,:integer
    add_column :listing_units,:max_people,:integer
  end

  def self.down
    remove_column :listing_units,:bed_count
    remove_column :listing_units,:max_people
  end
end
