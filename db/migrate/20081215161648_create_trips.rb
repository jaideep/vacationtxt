class CreateTrips < ActiveRecord::Migration
  def self.up
    create_table :trips do |t|
      t.column :user_id,:integer
      t.column :category,:string
      t.column :disount_id,:integer
      t.column :listing_id,:integer
      t.column :map_item_id,:integer
      t.timestamps
    end
  end

  def self.down
    drop_table :trips
  end
end
