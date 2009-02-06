class AddForeignKeysToCalendarItems < ActiveRecord::Migration
  def self.up
    add_column :listing_calendar_items, :listing_id, :integer
  end

  def self.down
    remove_column :listing_calendar_items, :listing_id
  end
end
