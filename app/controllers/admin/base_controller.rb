class Admin::BaseController < ApplicationController
  layout 'admin'

  before_action :ensure_admin

  private

    def ensure_admin
      unless current_user.admin?
        render_404
      end
    end
end
