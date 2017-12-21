class UserMailer < ApplicationMailer

  def confirmation(user)
    @user = user

    mail(to: @user.email, subject: 'Account Confimration')

    @user.update(confirmation_token_sent_at: Time.current) 
  end
end