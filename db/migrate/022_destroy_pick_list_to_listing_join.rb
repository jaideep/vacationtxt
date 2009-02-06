class DestroyPickListToListingJoin < ActiveRecord::Migration
  def self.up
    drop_table :listings_pick_lists
  end

  def self.down
    create_table :listings_pick_lists, :id=>false do |t|
      t.column :listing_id,:integer
      t.column :pick_list_id,:integer
      t.timestamps
    end
  end
end
