class DealsController < ApplicationController

  before_action :get_deals, only: :index
  before_action :set_deal, only: :show
  before_action :get_polled_deal, only: :polling
  skip_before_action :authenticate_user, only: [:index]

  def index
    @live_deals = @deals.live.includes(:images).chronologically_by_end_at
    @expired_deals = @deals.expired.includes(:images).reverse_chronologically_by_end_at
  end

  def show
  end

  def polling
    unless @deal.sellable
      render json: { error: 'The Deal has expired. Please reload the page to continue shopping' }
    end
  end

  private

    def set_deal
      @deal = Deal.find_by(id: params[:id])
      render_404 unless @deal.present?
    end

    def get_deals
      if params[:search].present? && params[:search][:deal_text].present?
        @deals = Deal.search_by_title_and_description(params[:search][:deal_text], params[:search][:deal_text])
      else
        @deals = Deal.all
      end
    end

    def get_polled_deal
      @deal = Deal.find_by(id: params[:id])
      if @deal.nil?
        render json: { error: 'Something went wrong. Please reload the page.' }, status: 422 and return
      end
    end
end
