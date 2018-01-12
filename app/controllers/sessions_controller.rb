class SessionsController < ApplicationController
  include Controllers::Rememberable
  skip_before_action :authenticate_user, except: [:destroy]
  before_action :ensure_logged_out, only: [:new, :create]
  before_action :fetch_user, only: [:create]
  before_action :ensure_user_confirmed, only: [:create]
  before_action :ensure_user_active, only: [:create]

  def new
  end

  def create
    if @user.try(:authenticate, params[:user][:password])
      create_remember_me_cookie if params[:remember_me].present?
      session[:user_id] = @user.id
      session[:order_id] = current_user.orders.where(state: 'cart').first.try(:id)

      flash[:notice] = t(:login_successfull, scope: [:flash, :notice])
      after_sign_in_path

    else
      redirect_to login_url, alert: t(:invalid_email_or_password, scope: [:flash, :alert])
    end
  end

  def destroy
    delete_remember_me_cookie
    delete_empty_order
    reset_session
    redirect_to login_url, notice: t(:logout_successfull, scope: [:flash, :notice])
  end

  private

    def fetch_user
      @user = User.find_by(email: params[:user][:email])
    end

    def ensure_user_confirmed
      if @user.confirmed_at.nil?
        redirect_to login_url, alert: t(:account_not_confirmed, scope: [:flash, :alert]) and return
      end
    end

    def after_sign_in_path
      if @user.admin?
        redirect_to admin_deals_path
      else
        redirect_to root_url
      end
    end

    def ensure_user_active
      unless @user.active?
        redirect_to login_url, alert: t(:account_inactive, scope: [:flash, :alert]) and return
      end      
    end

    def delete_empty_order
      if current_order.present?
        unless current_order.line_items.exists?
          current_order.destroy
        end
      end
    end
    
end
