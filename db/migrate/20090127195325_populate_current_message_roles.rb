class PopulateCurrentMessageRoles < ActiveRecord::Migration
  def self.up
    Message.all.each do |msg|
      msg.role = "OWNER"
      msg.save
    end
  end

  def self.down
  end
end
