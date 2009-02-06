class AddRegionToListings < ActiveRecord::Migration
  def self.up
    add_column :listings,:region,:string
  end

  def self.down
    remove_column :listings,:region
  end
end
