class CreateListingCalendarItems < ActiveRecord::Migration
  def self.up
    create_table :listing_calendar_items do |t|
      t.column :start,:date
      t.column :stop,:date
      t.column :item_type,:string
      t.timestamps
    end
  end

  def self.down
    drop_table :listing_calendar_items
  end
end
