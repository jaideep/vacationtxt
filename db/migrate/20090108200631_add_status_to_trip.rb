class AddStatusToTrip < ActiveRecord::Migration
  def self.up
    add_column :trips,:start,:datetime
    add_column :trips,:stop,:datetime
    add_column :trips,:status,:string
  end

  def self.down
    remove_column :trips,:status
    remove_column :trips,:start
    remove_column :trips,:stop
  end
end
