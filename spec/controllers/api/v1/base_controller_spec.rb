require "rails_helper"

RSpec.describe Api::V1::BaseController, type: :controller do
  it { expect(controller.class.ancestors).to include(ApplicationController) }
  
end
