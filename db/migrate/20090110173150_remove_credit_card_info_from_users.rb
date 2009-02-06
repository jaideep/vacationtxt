class RemoveCreditCardInfoFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users,:cc_number
    remove_column :users,:cc_expiry_month
    remove_column :users,:cc_expiry_year
    remove_column :users,:cc_security_number
    remove_column :users,:cc_name_on
  end

  def self.down
    add_column :users,:cc_number,:string
    add_column :users,:cc_expiry_month,:integer
    add_column :users,:cc_expiry_year,:integer
    add_column :users,:cc_security_number,:string
    add_column :users,:cc_name_on,:string
  end
end
