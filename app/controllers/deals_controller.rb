class DealsController < ApplicationController

  before_action :set_deal, only: [:show]

  def index
    @live_deals = Deal.live
    @expired_deals = Deal.expired    
  end

  def show
  end

  private

    def set_deal
      @deal = Deal.find_by(id: params[:id])
      render_404 unless @deal.present?
    end

end
