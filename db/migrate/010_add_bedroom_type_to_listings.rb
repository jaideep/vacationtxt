class AddBedroomTypeToListings < ActiveRecord::Migration
  def self.up
    add_column :listings,:bedroom_type,:string
  end

  def self.down
    remove_column :listings,:bedroom_type
  end
end
