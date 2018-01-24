class DealsController < ApplicationController

  before_action :set_deal, only: [:show]
  skip_before_action :authenticate_user, only: [:index]

  def index
    @live_deals = Deal.live.includes(:images).chronologically_by_end_at
    @expired_deals = Deal.expired.includes(:images).reverse_chronologically_by_end_at
  end

  def show
  end

  private

    def set_deal
      @deal = Deal.find_by(id: params[:id])
      render_404 unless @deal.present?
    end

end
