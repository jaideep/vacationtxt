class AddBidToTrip < ActiveRecord::Migration
  def self.up
    add_column :trips,:bid,:integer
  end

  def self.down
    remove_column :trips,:bid
  end
end
