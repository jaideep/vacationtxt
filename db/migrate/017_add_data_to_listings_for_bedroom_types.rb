class AddDataToListingsForBedroomTypes < ActiveRecord::Migration
  def self.up
    Listing.find(:all).each do |listing|
      listing.single_sleeper_count = 1
      listing.double_sleeper_count = 1
      listing.save!
    end
  end

  def self.down
    Listing.find(:all).each do |listing|
      listing.single_sleeper_count = 0
      listing.double_sleeper_count = 0
      listing.save!
    end
  end
end
