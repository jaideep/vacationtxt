class Click < ActiveRecord::Base
  belongs_to :map_item
  validates_presence_of :timestamp, :target
  validates_numericality_of :map_item_id
end
