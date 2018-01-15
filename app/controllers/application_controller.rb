class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user
  helper_method :current_user
  helper_method :current_order

  private
    def current_user
      if session[:user_id].nil?
        @current_user ||= fetch_user_from_cookie
      else
        @current_user ||= User.find_by(id: session[:user_id])
      end
    end

    def fetch_user_from_cookie
      if cookies[:remember_me].present?
        user = User.find_by(remember_me_token: cookies.encrypted[:remember_me])

        session[:user_id] = user.id if user.present? && user.confirmed_at? && user.active?

        user
      end
    end

    def current_order(create_new_order_if_nil: false)
      @current_order ||= Order.where(completed_at: nil).first
      
      if create_new_order_if_nil && @current_order.nil?
        @current_order = current_user.orders.create
      end

      @current_order
    end

    def authenticate_user
      if current_user.nil?
        redirect_to login_url, alert: t(:login_to_continue, scope: [:flash, :alert]) and return
      end
    end

    def ensure_logged_out
      redirect_to root_url, alert: t(:logout_to_continue, scope: [:flash, :alert]) and return if current_user.present?
    end

    def render_404
      render file: Rails.root.join('public', '404.html'), status: 404 and return
    end
end
