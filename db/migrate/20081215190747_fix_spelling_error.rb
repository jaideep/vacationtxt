class FixSpellingError < ActiveRecord::Migration
  def self.up
    remove_column :trips,:disount_id
    add_column :trips,:discount_id,:integer
  end

  def self.down
    remove_column :trips,:discount_id
    add_column :trips,:disount_id,:integer
  end
end
