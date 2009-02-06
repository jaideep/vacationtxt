class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :name, :string
      t.column :email, :string      
      t.column :password, :string
      t.column :phone, :string
      t.column :street_address, :string
      t.column :city, :string
      t.column :state, :string
      t.column :zip, :string
      t.column :cc_number, :string
      t.column :cc_expiry_month, :integer
      t.column :cc_expiry_year, :integer
      t.column :cc_security_number, :string
      t.column :cc_name_on, :string
      t.column :time_zone, :string
      t.column :text_me_start_time, :integer
      t.column :text_me_stop_time, :integer
      t.column :call_me_start_time, :integer
      t.column :call_me_stop_time, :integer
      t.column :timeout, :integer
      t.column :notify_of_failed, :boolean      
      t.column :response_preference, :string
      t.column :default_search_single_count, :integer
      t.column :default_search_double_count, :integer
      t.column :default_search_max_price, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
