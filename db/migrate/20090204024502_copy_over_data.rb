class CopyOverData < ActiveRecord::Migration
  def self.up
    ListingUnit.all.each do |l|
      l.bed_count = l.single_sleeper_count
      l.max_people = l.double_sleeper_count
      l.save
    end
  end

  def self.down
    ListingUnit.all.each do |l|
      l.single_sleeper_count = l.bed_count
      l.double_sleeper_count = l.max_people
      l.save
    end
  end
end
