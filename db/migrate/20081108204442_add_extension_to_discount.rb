class AddExtensionToDiscount < ActiveRecord::Migration
  def self.up
    add_column :discounts,:extension,:string
  end

  def self.down
    remove_column :discounts,:extension
  end
end
