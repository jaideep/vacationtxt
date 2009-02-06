class AddDetailsToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions,:renter_id,:integer
    add_column :transactions,:owner_id,:integer
    add_column :transactions,:listing_unit_id,:integer
    add_column :transactions,:price,:integer
    add_column :transactions,:start,:datetime
    add_column :transactions,:stop,:datetime
    add_column :transactions,:timestamp,:timestamp
  end

  def self.down
    remove_column :transactions,:renter_id
    remove_column :transactions,:owner_id
    remove_column :transactions,:listing_unit_id
    remove_column :transactions,:price
    remove_column :transactions,:start
    remove_column :transactions,:stop
    remove_column :transactions,:timestamp
  end
end
