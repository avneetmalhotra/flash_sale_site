class Admin::BaseController < ApplicationController
  layout 'admin'

  before_action :ensure_admin

  private

    def ensure_admin
      render file: Rails.root.join('public', '404.html'), status: 404 and return unless current_user.admin?
    end
end
