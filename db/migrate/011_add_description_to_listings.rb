class AddDescriptionToListings < ActiveRecord::Migration
  def self.up
    add_column :listings, :description, :string
  end

  def self.down
    remove_column :listings, :description
  end
end
