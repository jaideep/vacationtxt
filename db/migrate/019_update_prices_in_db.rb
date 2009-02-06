class UpdatePricesInDb < ActiveRecord::Migration
  def self.up
    Listing.find(:all).each do |listing|
      listing.price = 100
      listing.save!
    end
  end

  def self.down
    Listing.find(:all).each do |listing|
      listing.price = 0
      listing.save!
    end
  end
end
