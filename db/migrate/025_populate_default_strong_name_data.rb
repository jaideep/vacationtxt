class PopulateDefaultStrongNameData < ActiveRecord::Migration
  def self.up
    Listing.find(:all).each do |listing|
      listing.strong_name = "name me #{listing.id}"
      listing.save!
    end
  end

  def self.down
    Listing.find(:all).each do |listing|
      listing.strong_name = "."
      listing.save!
    end
  end
end
