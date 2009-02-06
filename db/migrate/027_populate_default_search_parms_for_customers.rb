class PopulateDefaultSearchParmsForCustomers < ActiveRecord::Migration
  def self.up
    #Customer.find(:all).each do |customer|
    #  customer.default_search_single_count = 1;
    #  customer.default_search_double_count = 1;
    #  customer.default_search_max_price = 500;
    #  customer.save!
    #end
  end

  def self.down
    #Customer.find(:all).each do |customer|
    #  customer.default_search_single_count = nil;
    #  customer.default_search_double_count = nil;
    #  customer.default_search_max_price = nil;
    #  customer.save!
    #end
  end
end
