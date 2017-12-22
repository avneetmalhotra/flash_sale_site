class RegistrationsController < ApplicationController
  before_action :ensure_logged_out, only: [:new, :create]
  skip_before_action :authenticate_user, only:[:new, :create]
  before_action :set_user, only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(new_user_params)
    if @user.save
      @user.send_confrimation_instructions
      redirect_to login_url, notice: t(:confirmation_email_sent, scope: [:flash, :notice])
    else
      render :new
    end
  end

  def edit
  end

  def update
    @user.update_with_password(update_user_params)
    if @user.errors.present?
      render :edit
    else
      redirect_to root_url, notice: t(:account_updated, scope: [:flash, :notice])
    end
  end

  private

    def new_user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def update_user_params
      params.require(:user).permit(:name, :password, :password_confirmation, :current_password)
    end

    def set_user
      @user = User.find_by(id: params[:id])
      render file: Rails.root.join('public', '404.html'), status: 404 and return if @user.try(:id) != current_user.id
    end

end
