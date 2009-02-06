class CreatePickLists < ActiveRecord::Migration
  def self.up
    create_table :pick_lists do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :pick_lists
  end
end
