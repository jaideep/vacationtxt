class CreateDiscounts < ActiveRecord::Migration
  def self.up
    create_table :discounts do |t|
      t.integer :map_item_id
      t.string :coupon_code
      t.string :image
      t.integer :priority
      t.text :description
      t.date :start_date
      t.date :end_date
      t.boolean :sms_enabled

      t.timestamps
    end
  end

  def self.down
    drop_table :discounts
  end
end
