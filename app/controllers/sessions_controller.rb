class SessionsController < ApplicationController
  include Controllers::Rememberable
  skip_before_action :authenticate_user, except: [:destroy]
  before_action :ensure_logged_out, only: [:new, :create]
  before_action :fetch_user, only: [:create]
  before_action :ensure_user_confirmed, only: [:create]

  def new
  end

  def create
    if @user.try(:authenticate, params[:user][:password])
      create_remember_me_cookie if params[:remember_me].present?
      session[:user_id] = @user.id
      
      flash[:notice] = t(:login_successfull, scope: [:flash, :notice])
      redirect_to admin_deals_path and return if @user.admin?
      redirect_to root_url, notice: t(:login_successfull, scope: [:flash, :notice])
    else
      redirect_to login_url, alert: t(:invalid_email_or_password, scope: [:flash, :alert])
    end
  end

  def destroy
    delete_remember_me_cookie
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
    
end
