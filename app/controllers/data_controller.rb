class DataController < ApplicationController
  def get_map_items
    items = []
    if params[:category]
      session[:map_context] = {:category=>params[:category]}
      items = (params[:category] == "DISCOUNTS") ? 
        MapItem.find(:all,:conditions=>"id in (select distinct map_item_id from discounts)") : 
        MapItem.find(:all,:conditions=>["category = ?",params[:category]])
    elsif params[:id]
      session[:map_context] = {:map_item_id=>params[:id]}
      items = MapItem.find(:all,:conditions=>"id = #{params[:id]}")
    end
    
    listings = []
    if session[:user_id]
      @user = User.find(session[:user_id])
      listings = @user.trips.select{|tr| tr.category == "LISTING" and tr.status == "BOOKED"}.map{|tr| tr.listing_unit.listing}
    end
    
    render :text=>"[#{listings.to_json(:only=>[:strong_name,:long,:lat,:description,:id],:methods=>:thumbnail_url)},
                    #{items.to_json(:only=>[:long,:lat,:category,:code,:name,:website_url,:id],:methods=>:has_discounts)}]"
  end
  
  def get_trip_items
    session[:map_context] = {:trip=>true}
    @user = User.find(session[:user_id])
    listings = @user.trips.select{|tr| tr.category == "LISTING"}
    businesses = @user.trips.select{|tr| tr.category == "MAP_ITEM"} #.map{|tr| tr.map_item}
    render_json("[#{listings.to_json(:only=>[:status,:id],:methods=>[:thumbnail_url,:name,:long,:lat,:description,:item_id])},
                 #{businesses.to_json(:only=>[:status,:id],:methods=>[:long,:lat,:item_category,:code,:name,:website_url,:item_id])}]")
  end
  
  def business_search
    term = params[:term]
    items = MapItem.find_by_search_term(term);
    render_json(items.to_json(:only=>[:id,:name]))
  end
  
private

  def render_json(json)
    respond_to{|wants| 
      wants.json{ 
        render :json => json
      }
    }
  end
end
