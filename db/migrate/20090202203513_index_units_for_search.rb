class IndexUnitsForSearch < ActiveRecord::Migration
  def self.up
    add_index :listing_units,["single_sleeper_count","double_sleeper_count","price"],:name=>"search_index"
  end

  def self.down
    remove_index :listing_units,:name=>"search_index"
  end
end
