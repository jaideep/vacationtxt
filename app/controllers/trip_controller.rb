class TripController < ApplicationController
  before_filter :authorize
  
  def add_map_item
    trip = @user.add_map_item_to_trip(MapItem.find(params[:id]))
    redirect_to :action=>:welcome,:controller=>:main,:see_trip=>"true",:see_trip_item=>trip.id
  end
  
  def add_discount
    trip = @user.add_discount_to_trip(Discount.find(params[:id]))
    redirect_to :action=>:welcome,:controller=>:main,:see_trip=>"true",:see_trip_item=>trip.id
  end
  
  def add_listing
    trip = @user.add_listing_to_trip(ListingUnit.find(params[:id]),
                                     DateTime.parse("#{params[:start_date]} #{params[:start_time][:hour]}:#{params[:start_time][:minute]}"),
                                     DateTime.parse("#{params[:stop_date]} #{params[:stop_time][:hour]}:#{params[:stop_time][:minute]}"))
    redirect_to :action=>:welcome,:controller=>:main,:see_trip=>"true",:see_trip_item=>trip.id
  end
  
  def clear_trip
    @user.clear_trip
    redirect_to :action=>:welcome,:controller=>:main
  end
  
  def check_availability
    trip = Trip.find(params[:id])
    if trip.status != "QUERIED" #dont duplicate check
      trip.update_attributes({:start=>DateTime.parse("#{params[:start_date]} #{params[:start_time_hour]}:#{params[:start_time_minute]}"),
                              :stop=>DateTime.parse("#{params[:stop_date]} #{params[:stop_time_hour]}:#{params[:stop_time_minute]}"),
                              :bid=>params[:bid].to_i})
      trip.save
      trip.check_availability
    end
    render :text=>"<status>checking</status>"
  end
  
  def book_item
    Trip.find(params[:id]).book!
    render :text=>"<status>booked</status>"
  end
  
  def counteroffer
    trip = Trip.find(params[:id])
    bid = params[:bid].to_i
    if bid == trip.price
      trip.book!
    else
      trip.update_attributes({:start=>DateTime.parse("#{params[:start_date]} #{params[:start_time_hour]}:#{params[:start_time_minute]}"),
                              :stop=>DateTime.parse("#{params[:stop_date]} #{params[:stop_time_hour]}:#{params[:stop_time_minute]}"),
                              :bid=>bid})
      trip.save
      trip.check_availability
    end
    render :text=>"<status>processed counteroffer</status>"
  end
  
  def remove
    Trip.find(params[:id]).destroy
    redirect_to :action=>:welcome,:controller=>:main,:see_trip=>"true"
  end
  
  def update_date
    trip = Trip.find(params[:id])
    trip.update_attributes({:start=>DateTime.parse("#{params[:start_date]} #{params[:start_time_hour]}:#{params[:start_time_minute]}"),
                            :stop=>DateTime.parse("#{params[:stop_date]} #{params[:stop_time_hour]}:#{params[:stop_time_minute]}")})
    trip.save
    render :text=>"<status>updated</status>"
  end
  
  def sms_trip
    @user.sms_trip
    render :text=>"<status>sent</status>"
  end
end
