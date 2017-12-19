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

    unless user.confirmed_at
      redirect_to login_url, notice: 'Account already confirmed'
    end

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
      # regenerating confirmation token here so that same link cannot be reused
      @user.regenerate_confirmation_token

      if has_confirmation_token_expired?
        redirect_to login_url, notice: 'Confirmation Link expired' and return
      end

      @user.update(confirmed_at: Time.current)
      flash[:notice] = 'Account Confirmed'
    else
      flash[:error] = "Invalid Link"
    end
      redirect_to login_url
  end

  private

    def email_valid?(email)
      email_regexp = Regexp.new(ENV['email_regex'])
      email =~ email_regexp
    end

    def has_confirmation_token_expired?
      Time.current - @user.confirmation_token_sent_at > eval(ENV['confirmation_token_validity'])
    end
end