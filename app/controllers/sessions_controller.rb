class SessionsController < ApplicationController
  include Controllers::Rememberable
  skip_before_action :authenticate_user, except: [:destroy]
  before_action :ensure_logged_out, only: [:new, :create]
  before_action :fetch_user, only: [:create]
  before_action :ensure_user_confirmed, only: [:create]
  # before_action :login_if_remember_user, only: [:new]

  def new
  end

  def create
    create_remember_me_cookie if params[:remember_me].present?
    session[:user_id] = @user.id
    redirect_to root_url, notice: t(:login_successfull, scope: [:flash, :notice]) and return
  end

  def destroy
    delete_remember_me_cookie
    reset_session
    redirect_to login_url, notice: t(:logout_successfull, scope: [:flash, :notice]) and return
  end

  private

    def fetch_user
      @user = User.find_by(email: params[:user][:email])
      unless @user.try(:authenticate, params[:user][:password])
        redirect_to login_url, alert: t(:invalid_email_or_password, scope: [:flash, :alert]) and return
      end
    end

    def ensure_user_confirmed
      if @user.confirmed_at.nil?
        redirect_to login_url, alert: t(:account_not_confirmed, scope: [:flash, :alert]) and return
      end
    end

    # def login_if_remember_user
    #   if cookies[:remember_me].present?
    #     @user = User.find_by(remember_me_token: cookies.encrypted[:remember_me])
        
    #     ensure_user_valid

    #     session[:user_id] = @user.id
    #     redirect_to root_url and return
    #   end
    # end

    # def ensure_user_valid
    #   redirect_to login_url and return if @user.nil?
    #   redirect_to login_url and return if @user.confirmed_at.nil?
    # end

end
