class AddLocationInfoToMapItem < ActiveRecord::Migration
  def self.up
    add_column :map_items, :lat, :double
    add_column :map_items, :long, :double
  end

  def self.down
    remove_column :map_items, :lat
    remove_column :map_items, :long
  end
end
