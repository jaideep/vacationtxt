class CreateBookings < ActiveRecord::Migration
  def self.up
    create_table :bookings do |t|
      t.column :check_in,:date
      t.column :check_out,:date
      t.timestamps
    end
  end

  def self.down
    drop_table :bookings
  end
end
