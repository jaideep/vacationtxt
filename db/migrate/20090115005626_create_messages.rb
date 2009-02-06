class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.column :text,:string
      t.column :trip_id,:integer
      t.column :user_id,:integer
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
