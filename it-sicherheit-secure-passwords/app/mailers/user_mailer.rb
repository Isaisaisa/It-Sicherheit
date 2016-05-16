class UserMailer < ActionMailer::Base
  default :from => "registraiton@tl.informatik.haw-hamburg.de"

  def registration_confirmation(user)
    @user = user
    mail(:to => "#{user.name} <#{user.email}>", :subject => "Registration Confirmation")
  end
end