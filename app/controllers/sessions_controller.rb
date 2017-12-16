class SessionsController < ApplicationController
  skip_before_action :authorize

  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user.try(:authenticate, params[:password])
      session[:user_id] = user.id
      redirect_to 'home#index', flash: "Welcome #{user.name}."
    else
      redirect_to login_url, alert: 'Invalid email/passord. Please try again.'
    end
  end

end