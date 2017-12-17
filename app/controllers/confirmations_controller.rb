class ConfirmationsController < ApplicationController
  skip_before_action :authorize

  def new
  end

  def create
    # email validaiton
    unless email_valid?(params[:email])
      redirect_to new_confirmation_url, alert: 'Invalid Email' and return
    end

    user = User.find_by(email: params[:email])
    if user
      RegistrationMailer.confirmation(user).deliver_now
      redirect_to login_url, notice: 'Confirmation Email Sent' 
    else
      redirect_to new_confirmation_url, alert: 'Invalid account'
    end

  end

  def confirm
    @user = User.find_by(confirmation_token: params[:confirmation_token])
    
    if @user
      @user.update(confirmed_at: Time.now)
      flash[:notice] = 'Account Confirmed'
    else
      flash[:error] = "Account couldn't be confirmed"
    end
      redirect_to login_url
  end

  private

    def email_valid?(email)
      email_regexp = Regexp.new(ENV['email_regex'])
      email =~ email_regexp
    end

end