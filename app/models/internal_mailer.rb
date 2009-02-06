class InternalMailer < ActionMailer::Base
  def brochure_request(params)
    @recipients   = [ADMIN_EMAIL,COMPANY_EMAIL]
    @from         = "vacationstxt@gmail.com"
    @subject      = "New Brochure Request!"
    @sent_on      = Time.now
    @content_type = "text/html"
    body[:params] = params
  end  
  
  def add_business(params)
    @recipients   = [ADMIN_EMAIL,COMPANY_EMAIL]
    @from         = "vacationstxt@gmail.com"
    @subject      = "User wants to Add Business!"
    @sent_on      = Time.now
    @content_type = "text/html"
    body[:params] = params
  end
  
  def recovered_password(user)
    @recipients   = [user.email]
    @from         = "vacationstxt@gmail.com"
    @subject      = "Vacationstxt.com Password Recovery"
    @sent_on      = Time.now
    @content_type = "text/html"
    body[:user] = user
  end

  def bug_or_issue(comments)
    @recipients   = COMPANY_EMAIL
    @subject      = "Vacationstxt.com ISSUE!"
    @sent_on      = Time.now
    @content_type = "text/html"
    body[:comments] = comments
  end
end
