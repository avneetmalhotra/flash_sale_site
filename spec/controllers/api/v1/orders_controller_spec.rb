require "rails_helper"

RSpec.describe Api::V1::OrdersController, type: :controller do
  it { expect(controller.class.ancestors).to include(Api::V1::BaseController) }
  it { is_expected.to use_before_action(:get_user) }
  let!(:line_item) { FactoryBot.create(:line_item) }
  let!(:deal) { line_item.deal }
  let!(:order) { line_item.order }
  let!(:user) { order.user }
  let!(:payment){ FactoryBot.create(:payment, :with_order_id, order_id: order.id) }

  describe 'GET #index' do

    context 'successful' do
      before { get :index, params: { token: user.api_token } }
      it { expect(assigns(:orders)).to include(order) }
      it { expect(assigns(:orders).count).to eq 1 }
      it { expect(assigns(:orders).first.id).to eq(order.id) }
      it { expect(JSON.parse(response.body).first['invoice_number']).to eql(order.invoice_number) }
    end

    context 'failure due to inavlid user' do
      before { get :index, params: { token: 'inavlid_token' } }
      it { expect(response.status).to eq(401) }
      it { expect(JSON.parse(response.body)).to eql({ 'error' => I18n.t(:not_authorized, scope: :api)}) }
    end

  end
end
