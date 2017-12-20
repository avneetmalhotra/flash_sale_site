class RegistrationsController < ApplicationController
  before_action :ensure_logged_out, only: [:new, :create]
  skip_before_action :authorize, only:[:new, :create]
  before_action :set_user, only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(new_user_params)
    if @user.save
      @user.send_confrimation_instructions
      redirect_to login_url, notice: "Confirmation email has been sent to your email address."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update(update_user_params)
      redirect_to root_url, notice: 'Acoount successfully updated'
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

    def ensure_logged_out
      redirect_to root_url if current_user
    end

    def set_user
      @user = User.find_by(id: params[:id])
    end
end
