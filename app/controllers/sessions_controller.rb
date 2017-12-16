class SessionsController < ApplicationController
  skip_before_action :authorize

  def new
  end

  def create
    user = User.find_by(email: params[:user][:email])

    if user.try(:authenticate, params[:user][:password])
      session[:user_id] = user.id
      redirect_to root_url, notice: "Welcome #{user.name}."
    else
      redirect_to login_url, alert: 'Invalid email/passord. Please try again.'
    end
  end

  def destroy
    session.clear
    redirect_to login_url, notice: 'Successfully logged out.'
  end

end