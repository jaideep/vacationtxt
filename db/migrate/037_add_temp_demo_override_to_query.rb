class AddTempDemoOverrideToQuery < ActiveRecord::Migration
  def self.up
    add_column :queries,:phone_override,:string
  end

  def self.down
    remove_column :queries,:phone_override
  end
end
