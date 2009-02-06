class CreateListingUnits < ActiveRecord::Migration
  def self.up
    create_table :listing_units do |t|
      t.integer  :listing_id
      t.integer  :single_sleeper_count
      t.integer  :double_sleeper_count
      t.integer  :price
      t.string   :strong_name
      t.timestamps
    end
  end

  def self.down
    drop_table :listing_units
  end
end
