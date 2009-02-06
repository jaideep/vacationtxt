class UserMailer < ActionMailer::Base
  
  def welcome(user)
    @recipients   = [user.email]
    @from         = "vacationstxt@gmail.com"
    @subject      = "Welcome to VacationsTxt.com!"
    @sent_on      = Time.now
    @content_type = "text/html"
    body[:username] = user.email
    body[:password] = user.password
  end
end
