require "rails_helper"

RSpec.describe HomeController, type: :controller do
  it { expect(controller.class.ancestors).to include(ApplicationController) }
  
  it { is_expected.to use_before_action(:get_deals) }

  describe 'GET #index' do
    context 'when user is logged in' do
      let!(:user) { FactoryBot.create(:user) }
      before { request.session[:user_id] = user.id }
      context 'get live deals' do
        let!(:live_deal) { FactoryBot.create(:deal) }
        before { live_deal.update_columns(publishing_date: Time.current, start_at: Time.current, end_at: 1.day.after) }        
        before { get :index }
        it { expect(assigns(:live_deals).count).to eq 1 }
        it { expect(assigns(:live_deals)).to include(live_deal) }
      end
      context 'get past deals' do
        let!(:expired_deal) { FactoryBot.create(:deal) }
        before { expired_deal.update_columns(publishing_date: 2.day.before, start_at: 2.day.before, end_at: 1.day.before) }        
        before { get :index }
        it { expect(assigns(:live_deals).count).to eq 0 }
        it { expect(assigns(:expired_deals).count).to eq 1 }
        it { expect(assigns(:expired_deals)).to include(expired_deal) }
      end
    end

    context 'when no user is logged in' do
      context 'get live deals' do
        let!(:live_deal) { FactoryBot.create(:deal) }
        before { live_deal.update_columns(publishing_date: Time.current, start_at: Time.current, end_at: 1.day.after) }        
        before { get :index }
        it { expect(assigns(:live_deals).count).to eq 1 }
        it { expect(assigns(:live_deals)).to include(live_deal) }
      end
      context 'get past deals' do
        let!(:expired_deal) { FactoryBot.create(:deal) }
        before { expired_deal.update_columns(publishing_date: 2.day.before, start_at: 2.day.before, end_at: 1.day.before) }        
        before { get :index }
        it { expect(assigns(:live_deals).count).to eq 0 }
        it { expect(assigns(:expired_deals).count).to eq 1 }
        it { expect(assigns(:expired_deals)).to include(expired_deal) }
      end
    end
  end

end

