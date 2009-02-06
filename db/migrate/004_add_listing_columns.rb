class AddListingColumns < ActiveRecord::Migration
  def self.up
    add_column :listings, :owner_id, :integer
    add_column :listings, :street_address, :string
    add_column :listings, :city, :string
    add_column :listings, :state, :string
    add_column :listings, :zip, :string    
  end

  def self.down
    remove_column :listings, :owner_id
    remove_column :listings, :street_address
    remove_column :listings, :city
    remove_column :listings, :state
    remove_column :listings, :zip
  end
end
