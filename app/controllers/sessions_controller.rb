class SessionsController < ApplicationController
  skip_before_action :authorize
  before_action :ensure_logged_out, only: [:new, :create]
  before_action :login_if_remember_user, only: [:new]

  def new
  end

  def create
    @user = User.find_by(email: params[:user][:email])

    if @user.try(:authenticate, params[:user][:password])
      if @user.confirmed_at.nil?
        redirect_to login_url, alert: 'Account not confirmed' and return
      end

      create_remember_me_cookie if params[:remember_me] == 'yes'

      session[:user_id] = @user.id
      redirect_to root_url, notice: "Welcome #{@user.name}."
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

    def create_remember_me_cookie
      # deleteing old cookie
      cookies.encrypted[:remember_me] = {
        value: @user.api_token,
        expires: 3.months.from_now,
        domain: request.domain
      }
    end

    def delete_remember_me_cookie
      cookies.delete(:remember_me, domain: request.domain)
    end

    def login_if_remember_user
      if cookies[:remember_me].present?
        user = User.find_by(api_token: cookies.encrypted[:remember_me])
        session[:user_id] = user.id

        redirect_to root_url, notice: "Welcome #{user.name}."
      end
    end

    def ensure_logged_out
      redirect_to '/' if current_user
    end

end