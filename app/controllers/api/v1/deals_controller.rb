class Api::V1::DealsController < Api::V1::BaseController

  def live
    @live_deals = Deal.live.chronologically_by_end_at
    
    if @live_deals.empty?
      render json: { error: I18n.t(:no_live_deals, scope: [:api, :deal]) }
    else
      render json: @live_deals
    end
  end

  def expired
    @expired_deals = Deal.expired.reverse_chronologically_by_end_at
    
    if @expired_deals.empty?
      render json: { error: I18n.t(:no_expired_deals, scope: [:api, :deal]) }
    else
      render json: @expired_deals
    end
  end

end
