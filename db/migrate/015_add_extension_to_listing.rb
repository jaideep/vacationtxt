class AddExtensionToListing < ActiveRecord::Migration
  def self.up
    add_column :listings, :extension, :string
  end

  def self.down
    remove_column :listings, :extension
  end
end
