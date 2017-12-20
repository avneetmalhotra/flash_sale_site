class ConfirmationsController < ApplicationController
  skip_before_action :authorize
  before_action :ensure_logged_out
  before_action :fetch_user, only: [:create]
  before_action :redirect_if_already_confirmed, only: [:create]
  before_action :fetch_user_from_confirmation_token, only: [:confirm]
  before_action :redirect_if_confirmation_token_expired, only: [:confirm]

  def new
  end

  def create
    @user.send_confrimation_instructions
    redirect_to login_url, notice: 'Confirmation Email Sent' 
  end

  def confirm
    @user.update(confirmed_at: Time.current)
    redirect_to login_url, notice: 'Your account has been successfully confirmed. Please log in.'
  end

  private

    def has_confirmation_token_expired?
      Time.current - @user.confirmation_token_sent_at > CONFIRMATION_TOKEN_VALIDITY
    end

    def ensure_logged_out
      redirect_to root_url and return if current_user.present?
    end

    def fetch_user
      @user = User.find_by(email: params[:email])
      if @user.nil?
        redirect_to new_confirmation_url, notice: 'Invalid Account'
      end
    end

    def redirect_if_already_confirmed
      if @user.confirmed_at.present?
        redirect_to login_url, notice: 'Account Already confirmed' and return
      end
    end

    def fetch_user_from_confirmation_token
      @user = User.find_by(confirmation_token: params[:confirmation_token])
      render file: Rails.root.join('public', '404.html'), status: 404 and return if @user.nil?
    end

    def redirect_if_confirmation_token_expired
      if has_confirmation_token_expired?
        redirect_to login_url, notice: 'Confirmation Link expired' and return
      end
    end
end
