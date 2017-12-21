class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user
  helper_method :current_user

  private
    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end

    def authenticate_user
      if current_user.nil?
        redirect_to login_url, alert: t(:login_to_continue, scope: [:flash, :alert]) and return
      end
    end

    def ensure_logged_out
      redirect_to root_url, alert: t(:logout_to_continue, scope: [:flash, :alert]) and return if current_user.present?
    end
end
