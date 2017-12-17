class RegistrationMailer < ApplicationMailer

  def confirmation(user)
    @user = user

    mail(to: user.email, subject: 'Account Confimration')
  end
end