class RegistrationsController < ApplicationController
  helper ErrorHelper
  skip_before_action :authorize
  before_action :ensure_logged_out, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(new_user_params)
    respond_to do |format|
      if @user.save
        RegistrationMailer.confirmation(@user).deliver_now

        format.html { redirect_to login_url, notice: "Confirmation email has been sent to your email address." }
      else
        format.html { render :new }
      end
    end
  end

  private

    def new_user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def ensure_logged_out
      redirect_to '/' if current_user
    end
end