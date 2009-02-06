class ModalController < ApplicationController
  layout false
  
  def business_search
  end
  
  def rental_search
    @param_map = (session[:map_context] and session[:map_context][:bed_count]) ? session[:map_context] : {}
  end
  
  def trip_item
    @trip = Trip.find(params[:id])
  end
end
