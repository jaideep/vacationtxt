class AddActiveFieldToListings < ActiveRecord::Migration
  def self.up
    add_column :listings, :active, :boolean
  end

  def self.down
    remove_column :listings, :active
  end
end
