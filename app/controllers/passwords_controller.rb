class PasswordsController < ApplicationController
  skip_before_action :authenticate_user
  before_action :ensure_logged_out
  before_action :fetch_user, only: [:create]
  before_action :fetch_user_from_password_reset_token, only: [:edit, :update]
  before_action :ensure_password_reset_token_validity, only: [:edit, :update]

  def new
  end

  def create
    @user.send_password_reset_instructions
    redirect_to login_url, notice: t(:password_reset_email_sent, scope: [:flash, :notice])
  end

  def edit
  end

  def update
    @user.reset_password(password_reset_params)
    if @user.errors.present?
      render 'edit'
    else
      redirect_to login_url, notice: t(:password_successfully_reset, scope: [:flash, :notice])
    end
  end

  private

    def fetch_user
      @user = User.find_by(email: params[:email])
      if @user.nil?
        redirect_to new_password_url, alert: t(:invalid_account, scope: [:flash, :alert]) and return
      end
    end

    def fetch_user_from_password_reset_token
      @user = User.find_by(password_reset_token: params[:password_reset_token])
      render file: Rails.root.join('public', '404.html'), status: 404 and return if @user.nil?
    end

    def ensure_password_reset_token_validity
      if @user.password_reset_token_expired?
        redirect_to login_url, alert: t(:invalid_password_reset_token, scope: [:flash, :alert]) and return
      end
    end

    def password_reset_params
      params.require(:user).permit(:password, :password_confirmation)
    end

end
