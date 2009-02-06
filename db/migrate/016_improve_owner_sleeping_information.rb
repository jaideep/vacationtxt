class ImproveOwnerSleepingInformation < ActiveRecord::Migration
  def self.up
    remove_column :listings,:bedroom_type
    add_column :listings,:single_sleeper_count, :integer
    add_column :listings,:double_sleeper_count, :integer
  end

  def self.down
    add_column :listings,:bedroom_type,:string
    remove_column :listings,:single_sleeper_count
    remove_column :listings,:double_sleeper_count
  end
end
