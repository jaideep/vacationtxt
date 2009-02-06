class AddSearchParmsToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :default_search_single_count, :integer
    add_column :customers, :default_search_double_count, :integer
    add_column :customers, :default_search_max_price, :integer
  end

  def self.down
    remove_column :customers, :default_search_single_count
    remove_column :customers, :default_search_double_count
    remove_column :customers, :default_search_max_price
  end
end
