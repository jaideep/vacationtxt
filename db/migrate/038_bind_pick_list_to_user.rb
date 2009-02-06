class BindPickListToUser < ActiveRecord::Migration
  def self.up
    add_column :pick_lists,:user_id,:integer
  end

  def self.down
    remove_column :pick_lists,:user_id
  end
end
