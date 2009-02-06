class IndexMessages < ActiveRecord::Migration
  def self.up
    add_index :messages,'user_id'
    add_index :messages,'trip_id'
  end

  def self.down
    remove_index :messages,'user_id'
    remove_index :messages,'trip_id'
  end
end
