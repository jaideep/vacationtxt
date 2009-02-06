class AddRoleToMessage < ActiveRecord::Migration
  def self.up
    add_column :messages,:role,:string
  end

  def self.down
    remove_column :messages,:role
  end
end
