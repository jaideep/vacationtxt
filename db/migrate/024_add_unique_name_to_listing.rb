class AddUniqueNameToListing < ActiveRecord::Migration
  def self.up
    add_column :listings, :strong_name, :string
  end

  def self.down
    remove_column :listings, :strong_name
  end
end
