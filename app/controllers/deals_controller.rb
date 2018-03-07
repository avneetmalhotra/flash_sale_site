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
    if @deal.sellable?
      render json: { message: I18n.t(:is_live, scope: [:deal, :polling]) }
    else
      render json: { error: I18n.t(:expired, scope: [:deal, :polling, :error]) }, status: 422
    end
  end

  private

    def set_deal
      @deal = Deal.find_by(id: params[:id])
      unless @deal.present?
        render_404
      end
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
        render json: { error: I18n.t(:invalid_deal, scope: [:deal, :polling, :error]) }, status: 404 and return
      end
    end
end
