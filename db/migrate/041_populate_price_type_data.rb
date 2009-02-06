class PopulatePriceTypeData < ActiveRecord::Migration
  def self.up
    Listing.find(:all).each do |listing|
      listing.pricing_type = 'FIXED'
      listing.save!
    end
  end

  def self.down
    Listing.find(:all).each do |listing|
      listing.pricing_type = nil
      listing.save!
    end
  end
end
