class IndexMapItems < ActiveRecord::Migration
  def self.up
    add_index :map_items,"category"
    add_index :map_items,"name"
  end

  def self.down
    remove_index :map_items,"category"
    remove_index :map_items,"name"
  end
end
