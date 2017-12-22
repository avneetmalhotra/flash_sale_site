class UserMailer < ApplicationMailer

  def confirmation_email(user_id)
    @user = User.find_by(id: user_id)
    
    mail(to: @user.email, subject: default_i18n_subject) unless @user.nil?
  end

  def password_reset_email(user_id)
    @user = User.find_by(id: user_id)

    mail(to: @user.email, subject: default_i18n_subject) unless @user.nil?
  end
end
