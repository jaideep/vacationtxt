class AddIndexesForUserIds < ActiveRecord::Migration
  def self.up
    add_index :listings, "user_id", :unique=>false
    add_index :rentals, "user_id", :unique=>false
    add_index :pick_lists, "user_id", :unique=>false
  end

  def self.down
    remove_index :listings, "user_id"
    remove_index :rentals, "user_id"
    remove_index :pick_lists, "user_id"
  end
end
