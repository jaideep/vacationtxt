class RemovePicklist < ActiveRecord::Migration
  def self.up
    drop_table :pick_lists
  end

  def self.down
    create_table :pick_lists do |t|
      t.column :check_in_date,:date
      t.column :check_out_date,:date
      t.column :user_id,:integer
      t.timestamps
    end
  end
end
