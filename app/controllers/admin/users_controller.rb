class Admin::UsersController < Admin::BaseController

  before_action :set_user, only: [:show, :edit, :update]
  before_action :ensure_not_admin, only: [:edit, :update]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(new_user_params)
    if @user.save
      redirect_to admin_users_url, notice: t(:confirmation_email_sent, scope: [:flash, :notice])
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(update_user_params)
      redirect_to admin_users_url, notice: t(:customer_account_unpdated, scope: [:flash, :notice])
    else
      render :edit
    end
  end


  private

    def set_user
      @user = User.find_by(id: params[:id])
      render_404 unless @user.present?
    end

    def new_user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :active)
    end

    def update_user_params
      params.require(:user).permit(:name, :active, :password, :password_confirmation)
    end

    def ensure_not_admin
      redirect_to admin_users_url, alert: t(:not_authorized, scope: [:flash, :alert]) if @user.admin?
    end
end 
