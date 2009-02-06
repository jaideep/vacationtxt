class TripAgent
  attr_reader :listings
  attr_reader :map_items
  attr_reader :discounts
  
  def initialize(user)
    container = {"LISTING"=>[],"MAP_ITEM"=>[],"DISCOUNT"=>[]}
    user.trips.each{|trip_item| container[trip_item.category] << trip_item}
    @listings = container["LISTING"]
    @map_items = container["MAP_ITEM"]
    @discounts = container["DISCOUNT"]
  end
end