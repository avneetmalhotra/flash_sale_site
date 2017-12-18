class RegistrationsController < ApplicationController
  helper ErrorHelper
  before_action :ensure_logged_out, only: [:new, :create]
  skip_before_action :authorize, only:[:new, :create]
  before_action :set_user, only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        RegistrationMailer.confirmation(@user).deliver_now
        format.html { redirect_to login_url, notice: "Confirmation email has been sent to your email address." }
      else
        format.html { render :new }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to '/', notice: 'Acoount successfully updated' }
      else
        format.html { render :edit }
      end
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def ensure_logged_out
      redirect_to '/' if current_user
    end

    def set_user
      @user = User.find_by(id: params[:id])
    end
end