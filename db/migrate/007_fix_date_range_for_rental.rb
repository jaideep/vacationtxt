class FixDateRangeForRental < ActiveRecord::Migration
  def self.up
    add_column :rentals, :rental_date_end, :date
  end

  def self.down
    remove_column :rentals, :rental_date_end
  end
end
