class SessionsController < ApplicationController
  include Controllers::Rememberable
  skip_before_action :authorize, except: [:destroy]
  before_action :ensure_logged_out, only: [:new, :create]
  before_action :login_if_remember_user, only: [:new]

  def new
  end

  def create
    @user = User.find_by(email: params[:user][:email])

    if @user.try(:authenticate, params[:user][:password])
      if @user.confirmed_at.nil?
        redirect_to login_url, alert: 'Please confirm your account to log in.' and return
      end

      create_remember_me_cookie if params[:remember_me].present?

      session[:user_id] = @user.id
      redirect_to root_url
    else
      redirect_to login_url, alert: 'Invalid email/passord. Please try again.'
    end
  end

  def destroy
    delete_remember_me_cookie
    session.clear
    redirect_to login_url, notice: 'Successfully logged out.'
  end

  private

    def login_if_remember_user
      if cookies[:remember_me].present?
        user = User.find_by(remember_me_token: cookies.encrypted[:remember_me])
        session[:user_id] = user.id

        redirect_to root_url and return
      end
    end

    def ensure_logged_out
      if current_user.present?
        redirect_to root_url and return 
      end
    end

end