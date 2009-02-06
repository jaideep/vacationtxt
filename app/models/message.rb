class Message < ActiveRecord::Base
  belongs_to :trip
  belongs_to :user
  
  ROLES=["OWNER","RENTER"]
  
  validates_presence_of :role,:trip_id,:user_id
  validates_inclusion_of :role, :in=>ROLES
  
  def deliver_response(data)
    if self.role == "OWNER"
      self.trip.process_owner_response(data)
    elsif self.role == "RENTER"
      self.trip.process_renter_response(data)
    end
  end
end
