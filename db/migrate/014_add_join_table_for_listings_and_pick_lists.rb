class AddJoinTableForListingsAndPickLists < ActiveRecord::Migration
  def self.up
    create_table :listings_pick_lists, :id=>false do |t|
      t.column :listing_id,:integer
      t.column :pick_list_id,:integer
      t.timestamps
    end
  end

  def self.down
    drop_table :listings_pick_lists
  end
end
