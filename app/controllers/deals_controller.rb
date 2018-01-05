class DealsController < ApplicationController

  before_action :set_deal, only: [:show]

  def show
    
  end

  private

    def set_deal
      @deal = Deal.find_by(id: params[:id])
      render_404 unless @deal.present?
    end

end
