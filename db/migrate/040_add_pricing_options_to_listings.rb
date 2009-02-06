class AddPricingOptionsToListings < ActiveRecord::Migration
  def self.up
    add_column :listings,:pricing_type,:string
  end

  def self.down
    remove_column :listings,:pricing_type
  end
end
