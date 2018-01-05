class HomeController < ApplicationController

  before_action :get_deals, only: [:index]
  skip_before_action :authenticate_user, only: [:index]

  def index
  end

  private

    def get_deals
      @deals_live = Deal.live.includes(:images)
      @deals_expired = Deal.expired.includes(:images).order(end_at: :desc).limit(2) if @deals_live.empty?
    end
end
