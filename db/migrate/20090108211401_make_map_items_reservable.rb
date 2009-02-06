class MakeMapItemsReservable < ActiveRecord::Migration
  def self.up
    add_column :map_items,:reservable,:boolean
  end

  def self.down
    add_column :map_items,:reservable
  end
end
