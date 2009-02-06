class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.column :email, :string
      t.column :password, :string
      t.column :name, :string
      t.column :phone, :string
      t.column :street_address, :string
      t.column :city, :string
      t.column :state, :string
      t.column :zip, :string
      t.column :response_preference, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :customers
  end
end
