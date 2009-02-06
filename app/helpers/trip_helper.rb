module TripHelper
  
  STATUS_TO_ACTION={'PICKED'=> "check_availability",
                    'QUERIED'=> "none",
                    'AVAILABLE'=> "book_item",
                    'UNAVAILABLE'=> "check_availability",
                    'BOOKED'=>"SEE_ITEM",
                    'NOT_RESERVABLE'=>"none",
                    'COUNTEROFFER'=>"counteroffer"}
                    
  STATUS_TO_DESCRIPTION={'PICKED'=> "<-Click to Check Vacancy",
                          'QUERIED'=> "",
                          'AVAILABLE'=> "<-Click to Book Item!",
                          'UNAVAILABLE'=> "<-Click to Check Vacancy",
                          'COUNTEROFFER'=> "<-Click to accept offer",
                          'BOOKED'=>"",
                          'NOT_RESERVABLE'=>""}
                          
  STATUS_TO_EXPLAIN={'PICKED'=> "Picked",
                      'QUERIED'=> "Waiting for Response",
                      'AVAILABLE'=> "Available!",
                      'UNAVAILABLE'=> "Not available on requested date.",
                      'BOOKED'=>"Booking Confirmed!",
                      'NOT_RESERVABLE'=>"Cant Reserve",
                      'COUNTEROFFER'=>"counteroffer"}
          
  def action(trip)
	  STATUS_TO_ACTION[trip.status]
  end
  
  def statusText(trip)
	  STATUS_TO_EXPLAIN[trip.status]
  end
  
  def datetime_cells(trip)
		if trip.can_modify_times
		  "<div id='start_date_tag'><span>Start Date:</span> #{calendariffic_input(false,"start_date","/images/calendariffic/date.png","pl_calendar_in_img_#{trip.id}",'%m/%d/%Y',trip.start.strftime("%m/%d/%Y"),{:readonly=>'true',:class=>"date_field cal_box"},{:alt => 'cal'})} at #{select_time(trip.start,{:prefix=>"start_time",:twelve_hour=>true})}</div><br/>" +
		  ((!trip.has_defined_ending?) ? "" : "<div id=\"stop_date_tag\"><span>End Date:</span> #{calendariffic_input(false,"stop_date","/images/calendariffic/date.png","pl_calendar_out_img_#{trip.id}",'%m/%d/%Y',trip.stop.strftime("%m/%d/%Y"),{:readonly=>'true',:class=>"date_field cal_box"},{:alt => 'cal'})} at #{select_time(trip.stop,{:prefix=>"stop_time",:twelve_hour=>true})}</div>")
		else
		  "<div id='start_date_tag'><span>Start Date:</span> #{trip.start.strftime("%m/%d/%Y %I:%M %p")}</div><div id='stop_date_tag'><span>End Date:</span> #{trip.stop.strftime("%m/%d/%Y %I:%M %p")}</div><input type='hidden' id='start_date' value='#{trip.start.strftime("%m/%d/%Y")}'/><input type='hidden' id='stop_date' value='#{trip.stop.strftime("%m/%d/%Y")}'/>"
		end
  end
  
  def bid_cell(trip)
    if trip.up_for_bid?
      if trip.status == 'PICKED'
			  "Bid $<input id=\"bid\" class=\"bid_holder\" type=\"text\" value=\"#{trip.bid}\"/> per night"
			elsif trip.status == 'COUNTEROFFER'
			  "Bid $<input id=\"bid\" class=\"bid_holder\" type=\"text\" style=\"color:red;\" value=\"#{trip.bid}\"/> per night.<br/>"\
			  "<span id='renter_counter_text'>Submit Counteroffer</span>"\
			   "<span id='renter_counter_link' style='display:none;'><a href='#' class='trip_action_button #{trip.status}' tag='#{trip.id}' controller='trip' action='#{action(trip)}' title='#{statusText(trip)}'>Submit Counteroffer</a></span>"
		  elsif trip.status == 'UNAVAILABLE' 
		    "<input id=\"bid\" type=\"hidden\" value=\"0\"/>&nbsp;"
		  else
		    "Bid $#{trip.bid} per night<input id=\"bid\" type=\"hidden\" value=\"#{trip.bid}\"/>"
		  end
		else
			"<input id=\"bid\" type=\"hidden\" value=\"0\"/>&nbsp;"
		end
  end
  
  def pricing_box(trip)
    if trip.up_for_bid?
      "Bid Status: #{pricing_span(trip)}"
    end
  end
  
  STATUS_COLOR_MAP = {"AVAILABLE"=>"33CC00",
                      "UNAVAILABLE"=>"FF0033",
                      "QUERIED"=>"CCCC33",
                      "COUNTEROFFER"=>"FF9900",
                      "PICKED"=>"3399FF"}
  STATUS_TEXT_MAP = {"AVAILABLE"=>"Accepted",
                     "UNAVAILABLE"=>"Declined",
                     "QUERIED"=>"Bidding",
                     "COUNTEROFFER"=>"Countered",
                     "PICKED"=>"Recommend bid of"}
  def pricing_span(trip)
    "<span id='pricing_status' style='color:\##{STATUS_COLOR_MAP[trip.status]}'>#{STATUS_TEXT_MAP[trip.status]} $#{trip.bid}</span>"
  end
end
