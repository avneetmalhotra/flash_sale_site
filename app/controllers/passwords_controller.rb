class PasswordsController < ApplicationController
  skip_before_action :authenticate_user
  before_action :ensure_logged_out
  before_action :fetch_user, only: [:create]
  before_action :ensure_user_confirmed, only: [:create]
  before_action :generate_password_reset_token, only: [:create]
  before_action :fetch_user_from_password_reset_token, only: [:edit, :update]
  before_action :ensure_password_reset_token_validity, only: [:edit, :update]

  def new
  end

  def create
    @user.update_columns(password_reset_token_sent_at: Time.current)
    UserMailer.password_reset_email(@user.id).deliver_later
    redirect_to login_url, notice: t(:password_reset_email_sent, scope: [:flash, :notice]) and return
  end

  def edit
  end

  def update
    if @user.update(password_reset_params)
      @user.update(password_reset_token: nil)
      redirect_to login_url, notice: t(:password_successfully_reset, scope: [:flash, :notice]) and return
    else
      render 'edit'
    end
  end

  private

    def fetch_user
      @user = User.find_by(email: params[:email])
      if @user.nil?
        redirect_to new_password_url, alert: t(:invalid_account, scope: [:flash, :alert]) and return
      end
    end

    def ensure_user_confirmed
      if @user.confirmed_at.nil?
        redirect_to login_url, alert: t(:account_not_confirmed, scope: [:flash, :alert]) and return
      end
    end

    def generate_password_reset_token
      token = nil
      loop do
        token = SecureRandom.hex(16)
        break unless User.where(password_reset_token: token).exists?
      end
      @user.update_columns(password_reset_token: token)
    end

    def fetch_user_from_password_reset_token
      @user = User.find_by(password_reset_token: params[:password_reset_token])
      render file: Rails.root.join('public', '404.html'), status: 404 and return if @user.nil?
    end

    def has_password_reset_token_expired?
      Time.current - @user.password_reset_token_sent_at > PASSWORD_RESET_TOKEN_VALIDITY
    end

    def ensure_password_reset_token_validity
      if has_password_reset_token_expired?
        redirect_to login_url, alert: t(:invalid_password_reset_token, scope: [:flash, :alert]) and return
      end
    end

    def password_reset_params
      params.require(:user).permit(:password, :password_confirmation)
    end

end
