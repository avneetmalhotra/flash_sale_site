class HomeController < ApplicationController

  before_action :get_deals, only: [:index]
  skip_before_action :authenticate_user, only: [:index]

  def index
  end

  private

    def get_deals
      @live_deals= Deal.live.includes(:images)
      @expired_deals = Deal.expired.includes(:images).order(end_at: :desc).limit(2) if @live_deals.empty?
    end
end
