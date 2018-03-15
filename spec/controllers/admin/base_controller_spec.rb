require "rails_helper"

Rspec.describe Admin::BaseController, type: :controller do
  it { is_expected.to use_before_action(:ensure_admin) }
end
