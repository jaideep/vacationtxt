module OwnerHelper
  def getPreviousMonthCalendarParams(year,month)
    if month > 1
      return {:action=>:see_listing_calendar, :year=>year,:month=>month - 1, :id=>params[:id]}
    else
      return {:action=>:see_listing_calendar, :year=>year-1,:month=>12, :id=>params[:id]}
    end
  end
  
  def getNextMonthCalendarParams(year,month)    
    if month < 12
      return {:action=>:see_listing_calendar, :year=>year,:month=>month + 1, :id=>params[:id]}
    else
      return {:action=>:see_listing_calendar, :year=>year+1,:month=>1, :id=>params[:id]}
    end
  end
  
end
