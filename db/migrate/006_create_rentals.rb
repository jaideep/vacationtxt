class CreateRentals < ActiveRecord::Migration
  def self.up
    create_table :rentals do |t|
      t.column :customer_id, :integer
      t.column :listing_id, :integer
      t.column :price, :double
      t.column :confirmed_date, :date
      t.column :rental_date, :date
      t.timestamps
    end
  end

  def self.down
    drop_table :rentals
  end
end
