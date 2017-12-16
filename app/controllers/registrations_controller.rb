class RegistrationsController < ApplicationController
  helper ErrorHelper
  skip_before_action :authorize

  def new
    @user = User.new
  end

  def create
    @user = User.new(new_user_params)
    respond_to do |format|
      if @user.save
        format.html { redirect_to root_url, notice: "#{@user.name} customer created" }
      else
        format.html { render :new }
      end
    end
  end

  private

    def new_user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end