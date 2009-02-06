class AddDaterangeToPickList < ActiveRecord::Migration
  def self.up
    add_column :pick_lists, :check_in_date, :date
    add_column :pick_lists, :check_out_date, :date
  end

  def self.down
    remove_column :pick_lists, :check_in_date
    remove_column :pick_lists, :check_out_date
  end
end
