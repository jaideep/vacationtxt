class CreateOwners < ActiveRecord::Migration
  def self.up
    create_table :owners do |t|
      t.column :username, :string
      t.column :password, :string
      t.column :name, :string
      t.column :email, :string
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
      t.timestamps
    end
  end

  def self.down
    drop_table :owners
  end
end
