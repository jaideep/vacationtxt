class AddMessageWaitingForUsers < ActiveRecord::Migration
  def self.up
    add_column :users,:message_waiting_id,:integer
    add_column :users,:message_waiting_timestamp,:datetime
  end

  def self.down
    remove_column :users,:message_waiting_id
    remove_column :users,:message_waiting_timestamp
  end
end
