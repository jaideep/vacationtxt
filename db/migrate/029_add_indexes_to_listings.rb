class AddIndexesToListings < ActiveRecord::Migration
  def self.up
    add_index :listings, ["single_sleeper_count","double_sleeper_count","price"], :name=>"main_search_index", :unique=>false
    add_index :listings, "owner_id", :unique=>false
  end

  def self.down
    remove_index :listings, :name=>"main_search_index"
    remove_index :listings, "owner_id"
  end
end
