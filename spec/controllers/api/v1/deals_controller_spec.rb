require "rails_helper"

RSpec.describe Api::V1::DealsController, type: :controller do
  it { expect(controller.class.ancestors).to include(Api::V1::BaseController) }
  
  describe 'GET #live' do
    let!(:live_deal) { FactoryBot.create(:deal) }
    before { live_deal.update_columns(publishing_date: Date.current, start_at: Time.current, end_at: 1.day.after) }
    before { get :live }
    it { expect(assigns(:live_deals)).to include(live_deal) }
    it { expect(assigns(:live_deals).count).to eq 1 }

    it { expect(JSON.parse(response.body).first['title']).to eq(live_deal.title)}
    it { expect(JSON.parse(response.body).count).to eq 1 }
  end

  describe 'GET #expired' do
    let!(:expired_deal) { FactoryBot.create(:deal) }
    before { expired_deal.update_columns(publishing_date: 2.day.before, start_at: 2.day.before, end_at: 1.day.before) }
    before { get :expired }
    it { expect(assigns(:expired_deals)).to include(expired_deal) }
    it { expect(assigns(:expired_deals).count).to eq 1 }

    it { expect(JSON.parse(response.body).first['title']).to eq(expired_deal.title)}
    it { expect(JSON.parse(response.body).count).to eq 1 }
  end
end
