class IndexTrips < ActiveRecord::Migration
  def self.up
    add_index :trips,'user_id'
  end

  def self.down
    remove_index :trips,'user_id'
  end
end
