class VacationLinkTime
  OPTIONS = [['1:00 AM',1],
             ['2:00 AM',2],
             ['3:00 AM',3],
             ['4:00 AM',4],
             ['5:00 AM',5],
             ['6:00 AM',6],
             ['7:00 AM',7],
             ['8:00 AM',8],
             ['9:00 AM',9],
             ['10:00 AM',10],
             ['11:00 AM',11],
             ['12:00 PM',12],
             ['1:00 PM',13],
             ['2:00 PM',14],
             ['3:00 PM',15],
             ['4:00 PM',16],
             ['5:00 PM',17],
             ['6:00 PM',18],
             ['7:00 PM',19],
             ['8:00 PM',20],
             ['9:00 PM',21],
             ['10:00 PM',22],
             ['11:00 PM',23],
             ['12:00 AM',24]]
             
  def self.options
    OPTIONS
  end
  
  def self.getDaysInMonth(year,month)
    if [1,3,5,7,8,10,12].include?(month)
      31
    elsif month != 2
      30
    else
      ((year % 4) == 0 and (year % 100) != 0)  ? 29 : 28; 
    end
  end
  
  def self.as_date_string(year,month,day)
    "#{year}/#{(month >= 10)? month : "0#{month}"}/#{(day >= 10) ? day : "0#{day}" }"
  end
  
  def self.as_date_database_string(year,month,day)
    "#{year}-#{(month >= 10)? month : "0#{month}"}-#{(day >= 10) ? day : "0#{day}" }"
  end
end
