class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authorize
  helper_method :current_user

  private
    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end

    def authorize
      if current_user.nil?
        redirect_to login_url, notice: 'Please login first'
      end
    end
end
