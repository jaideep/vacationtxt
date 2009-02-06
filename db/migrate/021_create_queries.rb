class CreateQueries < ActiveRecord::Migration
  def self.up
    create_table :queries do |t|
      t.column :pick_list_id, :integer
      t.column :listing_id, :integer
      t.column :state, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :queries
  end
end
