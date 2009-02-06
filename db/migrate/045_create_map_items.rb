class CreateMapItems < ActiveRecord::Migration
  def self.up
    create_table :map_items do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :website_url, :string
      t.column :street_address, :string
      t.column :city, :string
      t.column :state, :string
      t.column :zip, :string  
      t.column :category, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :map_items
  end
end
