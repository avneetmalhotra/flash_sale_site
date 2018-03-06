require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  it { expect(ApplicationController.ancestors).to include(ActionController::Base) }

  it { is_expected.to use_before_action(:authenticate_user) }

  # it { expect(ApplicationController).to receive(:protect_from_forgery).with(with: :exception) }
  
  it { is_expected.to use_before_action(:authenticate_user) }

end
