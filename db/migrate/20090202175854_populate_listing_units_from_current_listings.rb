class PopulateListingUnitsFromCurrentListings < ActiveRecord::Migration
  def self.up
    Listing.all.each do |listing|
      ListingUnit.new(:listing_id=>listing.id,
                      :single_sleeper_count=>listing.single_sleeper_count,
                      :double_sleeper_count=>listing.double_sleeper_count,
                      :price=>listing.price,
                      :strong_name=>listing.strong_name).save!
    end
  end

  def self.down
  end
end
