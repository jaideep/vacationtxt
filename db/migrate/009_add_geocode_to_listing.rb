class AddGeocodeToListing < ActiveRecord::Migration
  def self.up
    add_column :listings, :lat, :double
    add_column :listings, :long, :double
  end

  def self.down
    remove_column :listings, :lat
    remove_column :listings, :long
  end
end
