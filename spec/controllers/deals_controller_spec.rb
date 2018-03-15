require "rails_helper"

RSpec.describe DealsController, type: :controller do
  it { expect(controller.class.ancestors).to include(ApplicationController) }
  
  it { is_expected.to use_before_action(:get_deals) }
  it { is_expected.to use_before_action(:set_deal) }

  describe 'GET #index' do
    context 'when user logged in' do
      let!(:user) { FactoryBot.create(:user) }
      before { request.session[:user_id] = user.id }
      context 'when search params is not present' do
        let!(:live_deal){ FactoryBot.create(:deal, title: 'live_deal') }
        let!(:expired_deal){ FactoryBot.create(:deal, title: 'expired_deal') }
        before do
          live_deal.update_columns(publishing_date: Time.current, start_at: Time.current, end_at: 1.day.after)
          expired_deal.update_columns(publishing_date: 2.day.before, start_at: 2.day.before, end_at: 1.day.before)
          get :index
        end
        it { expect(assigns(:live_deals).count).to eq 1 }
        it { expect(assigns(:live_deals)).to include(live_deal) }
        it { expect(assigns(:expired_deals).count).to eq 1 }
        it { expect(assigns(:expired_deals)).to include(expired_deal) }
      end

      context 'when search params is present' do
        let!(:live_deal){ FactoryBot.create(:deal, title: 'live_deal', description: 'random description') }
        let!(:expired_deal){ FactoryBot.create(:deal, title: 'expired_deal', description: 'random description') }
        before do
          live_deal.update_columns(publishing_date: Time.current, start_at: Time.current, end_at: 1.day.after)
          expired_deal.update_columns(publishing_date: 2.day.before, start_at: 2.day.before, end_at: 1.day.before)
          get :index, params: { search: { deal_text: 'random'} }
        end
        it { expect(assigns(:live_deals).count).to eq 1 }
        it { expect(assigns(:live_deals)).to include(live_deal) }
        it { expect(assigns(:expired_deals).count).to eq 1 }
        it { expect(assigns(:expired_deals)).to include(expired_deal) }
      end
    end

    context 'when no user logged in' do
      context 'when search params is not present' do
        let!(:live_deal){ FactoryBot.create(:deal, title: 'live_deal') }
        let!(:expired_deal){ FactoryBot.create(:deal, title: 'expired_deal') }
        before do
          live_deal.update_columns(publishing_date: Time.current, start_at: Time.current, end_at: 1.day.after)
          expired_deal.update_columns(publishing_date: 2.day.before, start_at: 2.day.before, end_at: 1.day.before)
          get :index
        end
        it { expect(assigns(:live_deals).count).to eq 1 }
        it { expect(assigns(:live_deals)).to include(live_deal) }
        it { expect(assigns(:expired_deals).count).to eq 1 }
        it { expect(assigns(:expired_deals)).to include(expired_deal) }
      end

      context 'when search params is present' do
        let!(:live_deal){ FactoryBot.create(:deal, title: 'live_deal', description: 'random description') }
        let!(:expired_deal){ FactoryBot.create(:deal, title: 'expired_deal', description: 'random description') }
        before do
          live_deal.update_columns(publishing_date: Time.current, start_at: Time.current, end_at: 1.day.after)
          expired_deal.update_columns(publishing_date: 2.day.before, start_at: 2.day.before, end_at: 1.day.before)
          get :index, params: { search: { deal_text: 'random'} }
        end
        it { expect(assigns(:live_deals).count).to eq 1 }
        it { expect(assigns(:live_deals)).to include(live_deal) }
        it { expect(assigns(:expired_deals).count).to eq 1 }
        it { expect(assigns(:expired_deals)).to include(expired_deal) }
      end
    end
  end

  describe 'GET #show' do
    context 'when user logged in' do
      let!(:user) { FactoryBot.create(:user) }
      let!(:live_deal){ FactoryBot.create(:deal, title: 'live_deal', description: 'random description') }
      before do
        request.session[:user_id] = user.id
        live_deal.update_columns(publishing_date: Time.current, start_at: Time.current, end_at: 1.day.after)
      end
      context 'fails for invalid deal' do
        before { get :show, params: { id: 0 } }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
        it { expect(response.status).to eq(404) }
      end

      context 'successful' do
        before { get :show, params: { id: live_deal.id } }
        it { expect(response).to render_template(:show) }
      end
    end

    context 'when no user logged in' do
      before { get :show, params: { id: 1 } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }      
    end
  end

end
