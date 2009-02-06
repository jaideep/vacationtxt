class CreateClicks < ActiveRecord::Migration
  def self.up
    create_table :clicks do |t|
      t.column :map_item_id, :integer
      t.column :target, :string
      t.column :timestamp, :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :clicks
  end
end
