class Admin::DealsController < Admin::BaseController

  before_action :set_user, only: [:edit, :update, :show, :destroy]

  def index
    @deals = Deal.all
  end

  def new
    @deal = Deal.new
  end

  def create
    @deal = Deal.new(new_deal_params)
    if @deal.save
      redirect_to action: :index, notice: t(:deal_created, scope: [:flash, :notice])
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @deal.update(update_deal_params)
      redirect_to action: :index, notice: t(:deal_updated, scope: [:flash, :notice])
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    if @deal.destroy
      redirect_to action: :index, notice: t(:deal_successfully_destroyed, scope: [:flash, :notice])
    else
      render :show, notice: t(:deal_cannot_be_destroyed, scope: [:flash, :alert])
    end
  end

  private

    def new_deal_params
      params.require(:deal).permit(:title, :description, :price, :discount_price, :quantity, :publishing_date, images_attributes: [:avatar, :_destroy])
    end

    def update_deal_params
      params.require(:deal).permit(:title, :description, :price, :discount_price, :quantity, :publishing_date, images_attributes: [:id, :avatar, :_destroy])
    end

    def set_user
      @deal = Deal.find_by(id: params[:id])
      render file: Rails.root.join('public', '404.html'), status: 404 and return unless @deal.try(:id)
    end
end
