class PopulateAllMapItemsToNotBeReservable < ActiveRecord::Migration
  def self.up
    MapItem.all.each do |mi|
      mi.reservable = false
      mi.save
    end
  end

  def self.down
  end
end
