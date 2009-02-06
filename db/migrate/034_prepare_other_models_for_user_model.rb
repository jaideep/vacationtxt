class PrepareOtherModelsForUserModel < ActiveRecord::Migration
  def self.up
    add_column :listings, :user_id, :integer
    add_column :rentals, :user_id, :integer
  end

  def self.down
    remove_column :listings, :user_id
    remove_column :rentals, :user_id
  end
end
