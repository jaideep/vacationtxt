class RemoveQueries < ActiveRecord::Migration
  def self.up
    drop_table :queries
  end

  def self.down
    create_table :queries do |t|
      t.column :listing_id, :integer
      t.column :state, :string
      t.column :phone_override, :string
      t.column :check_in,:date
      t.column :check_out,:date
      t.column :user_id,:integer
      t.timestamps
    end
  end
end
