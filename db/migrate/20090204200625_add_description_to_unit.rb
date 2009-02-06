class AddDescriptionToUnit < ActiveRecord::Migration
  def self.up
    add_column :listing_units,:description,:string
  end

  def self.down
    remove_column :listing_units,:description
  end
end
