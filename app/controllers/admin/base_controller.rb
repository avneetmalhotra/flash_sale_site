class Admin::BaseController < ApplicationController
  layout 'admin'

  before_action :ensure_admin

  private

    def ensure_admin
      render_404 unless current_user.admin?
    end
end
