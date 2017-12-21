class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user
  helper_method :current_user

  private
    def current_user
      if session[:user_id].nil?
        @current_user ||= check_for_user_in_remember_me_cookie
      end
      @current_user ||= User.find_by(id: session[:user_id])
    end

    def check_for_user_in_remember_me_cookie
      if cookies[:remember_me].present?
        user = User.find_by(remember_me_token: cookies.encrypted[:remember_me])
        
        if user.present?
          session[:user_id] = user.id
        end

        user
      end
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
