class HomeController < ApplicationController

  before_action :render_admin_layout_for_admin

  def index
  end

  private

    def render_admin_layout_for_admin
      render layout: 'admin'
    end
end
