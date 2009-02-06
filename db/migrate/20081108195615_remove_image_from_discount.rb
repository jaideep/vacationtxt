class RemoveImageFromDiscount < ActiveRecord::Migration
  def self.up
    remove_column :discounts,:image
  end

  def self.down
    add_column :discounts,:image,:string
  end
end
