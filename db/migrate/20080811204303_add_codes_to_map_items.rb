class AddCodesToMapItems < ActiveRecord::Migration
  def self.up
    add_column :map_items,:code,:integer
  end

  def self.down
    remove_column :map_items,:code,:integer
  end
end
