class AddBooleanFlagsToMapItmes < ActiveRecord::Migration
  def self.up
    add_column :map_items,:has_reservations,:boolean
    add_column :map_items,:can_order_online,:boolean
    add_column :map_items,:can_buy_tickets,:boolean
    add_column :map_items,:has_discount_coupon,:boolean
    add_column :map_items,:has_map,:boolean
    add_column :map_items,:verified,:boolean
  end

  def self.down
    remove_column :map_items,:has_reservations
    remove_column :map_items,:can_order_online
    remove_column :map_items,:can_buy_tickets
    remove_column :map_items,:has_discount_coupon
    remove_column :map_items,:has_map
    remove_column :map_items,:verified
  end
end
