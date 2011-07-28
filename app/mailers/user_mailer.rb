class UserMailer < ActionMailer::Base
  helper :queries
  default from: "hQueryMcNoreply@mitre.org"

  def execution_notification(execution)
    @user = User.find(execution.query.user_id)
    @execution = execution
    mail(
      :to       => @user.email,
      :subject  => "[hQuery] Results for #{@execution.query.title}"
    )
  end
end