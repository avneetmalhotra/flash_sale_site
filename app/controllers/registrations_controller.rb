class RegistrationsController < ApplicationController
  before_action :ensure_logged_out, only: [:new, :create]
  skip_before_action :authenticate_user, only:[:new, :create]
  before_action :set_user, only: [:edit, :update]
  before_action :ensure_current_user, only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(new_user_params)
    if @user.save
      redirect_to login_url, notice: t(:confirmation_email_sent, scope: [:flash, :notice]) and return
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update(update_user_params)
      redirect_to root_url, notice: t(:account_updated, scope: [:flash, :notice]) and return
    else
      render :edit
    end
  end

  private

    def new_user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def update_user_params
      params.require(:user).permit(:name, :password, :password_confirmation)
    end

    def set_user
      @user = User.find_by(id: params[:id])
    end

    def ensure_current_user
      render file: Rails.root.join('public', '404.html'), status: 404 and return unless @user.id == current_user.id
    end
end
