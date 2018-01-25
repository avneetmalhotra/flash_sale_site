class Api::V1::DealsController < Api::V1::BaseController

  def live
    @live_deals = Deal.live.chronologically_by_end_at
    
    render json: @live_deals
  end

  def expired
    @expired_deals = Deal.expired.reverse_chronologically_by_end_at
    
    render json: @expired_deals
  end

end
