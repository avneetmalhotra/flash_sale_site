class ConfirmationsController < ApplicationController
  skip_before_action :authenticate_user
  before_action :ensure_logged_out
  before_action :fetch_user, only: [:create]
  before_action :ensure_not_confirmed, only: [:create]
  before_action :fetch_user_from_confirmation_token, only: [:confirm]
  before_action :ensure_confirmation_token_validity, only: [:confirm]

  def new
  end

  def create
    @user.update(confirmation_token_sent_at: Time.current) 
    @user.send_confrimation_instructions
    redirect_to login_url, notice: t(:confirmation_email_sent, scope: [:flash, :notice]) and return
  end

  def confirm
    @user.update_columns(confirmed_at: Time.current)
    @user.update(confirmation_token: nil) 
    redirect_to login_url, notice: t(:account_confirmed, scope: [:flash, :notice]) and return
  end

  private

    def has_confirmation_token_expired?
      Time.current - @user.confirmation_token_sent_at > CONFIRMATION_TOKEN_VALIDITY
    end

    def fetch_user
      @user = User.find_by(email: params[:email])
      if @user.nil?
        redirect_to new_confirmation_url, alert: t(:invalid_account, scope: [:flash, :alert]) and return
      end
    end

    def ensure_not_confirmed
      if @user.confirmed_at.present?
        redirect_to login_url, alert: t(:account_already_confirmed, scope: [:flash, :alert]) and return
      end
    end

    def fetch_user_from_confirmation_token
      @user = User.find_by(confirmation_token: params[:confirmation_token])
      render file: Rails.root.join('public', '404.html'), status: 404 and return if @user.nil?
    end

    def ensure_confirmation_token_validity
      if has_confirmation_token_expired?
        redirect_to login_url, alert: t(:invalid_confirmation_token, scope: [:flash, :alert]) and return
      end
    end
end
