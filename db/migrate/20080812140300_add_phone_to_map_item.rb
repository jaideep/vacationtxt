class AddPhoneToMapItem < ActiveRecord::Migration
  def self.up
    add_column :map_items,:phone,:string
  end

  def self.down
    remove_column :map_items,:phone
  end
end
