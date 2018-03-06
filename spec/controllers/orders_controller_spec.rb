require "rails_helper"

RSpec.describe OrdersController, type: :controller do

  it { expect(OrdersController.ancestors).to include(ApplicationController) }

  it { is_expected.to use_before_action(:get_order) }

  describe 'GET #cart' do
    context 'when user logged in' do
      let!(:user) { FactoryBot.create(:user) }
      before { request.session[:user_id] = user.id }
      it { expect(response.status).to eq(200) }
      # it { expect(response).to render_template(:cart) }
    end

    context 'when logged out' do
      before { get :cart }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }      
    end
  end

  describe 'DELETE #destroy' do
    context 'when user logged in' do
      context 'fails for invalid order' do
        let!(:user) { FactoryBot.create(:user) }
        before { request.session[:user_id] = user.id }
        before do
          delete :destroy, params: { invoice_number: 'INV-random_token' }
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end

      context 'order destruction fails' do
        let!(:order) { FactoryBot.create(:order, :in_cart, user_email: 'random_mail@email.com') }
        let!(:user) { order.user }
        before { request.session[:user_id] = user.id }
        before do
          allow_any_instance_of(Order).to receive(:destroy).and_return(false)
          delete :destroy, params: { invoice_number: order.invoice_number }
        end
        it { expect(response).to redirect_to(cart_path) }
        it { expect(request.flash.alert).to eql(assigns(:order).pretty_errors) }
      end

      context 'order destroyed successfully' do
        let!(:order) { FactoryBot.create(:order, :in_cart, user_email: 'random_mail@email.com') }
        let!(:user) { order.user }
        before { request.session[:user_id] = user.id }
        before do
          allow_any_instance_of(Order).to receive(:destroy).and_return(true)
          delete :destroy, params: { invoice_number: order.invoice_number }
        end
        it { expect(response).to redirect_to(root_path) }
        it { expect(request.flash.notice).to eql(I18n.t(:cart_emptied, scope: [:flash, :notice])) }
      end
    end

    context 'when logged out' do
      before { delete :destroy, params: { invoice_number: 'INV-random_token' } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }      
    end
  end

  describe 'GET #show' do
    context 'when user logged in' do
      context 'fails for invalid order' do
        let!(:user) { FactoryBot.create(:user) }
        before { request.session[:user_id] = user.id }
        before do
          get :show, params: { invoice_number: 'INV-random_token' }
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end

      context 'show order successfully' do
        let!(:order) { FactoryBot.create(:order, :in_cart, user_email: 'random_mail@email.com') }
        let!(:user) { order.user }
        before { request.session[:user_id] = user.id }
        before { get :show, params: { invoice_number: order.invoice_number } }
        it { expect(response.status).to eq(200) }
        it { expect(response).to render_template(:show) }
      end
    end

    context 'when logged out' do
      before { get :show, params: { invoice_number: 'INV-random_token' } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }      
    end
  end

  describe 'GET #index' do
    context 'when user logged in' do
      context 'ready_for_delivery_orders' do
        let!(:complete_order) { FactoryBot.create(:order, :completed, user_email: 'random_mail@email.com') }
        let!(:user) { complete_order.user }
        before { request.session[:user_id] = user.id }
        before { get :index }
        it { expect(assigns(:ready_for_delivery_orders)).to include(complete_order) }
        it { expect(response).to render_template(:index) }
      end

      context 'delivered_orders' do
        let!(:delivered_order) { FactoryBot.create(:order, :delivered, user_email: 'random_mail@email.com') }
        let!(:user) { delivered_order.user }
        before { request.session[:user_id] = user.id }
        before { get :index }
        it { expect(assigns(:delivered_orders)).to include(delivered_order) }
        it { expect(response).to render_template(:index) }
      end

      context 'cancelled_orders' do
        let!(:cancelled_order) { FactoryBot.create(:order, :cancelled, user_email: 'random_mail@email.com') }
        let!(:user) { cancelled_order.user }
        before { request.session[:user_id] = user.id }
        before { get :index }
        it { expect(assigns(:cancelled_orders)).to include(cancelled_order) }
        it { expect(response).to render_template(:index) }
      end
    end

    context 'when logged out' do
      before { get :index }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }      
    end
  end

  describe 'PATCH #cancel' do
    context 'when user logged in' do
      context 'fails for invalid order' do
        let!(:user) { FactoryBot.create(:user) }
        before { request.session[:user_id] = user.id }
        before { patch :cancel, params: { invoice_number: 'INV-random_token' } }
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end

      context 'order cancellation fails' do
        let!(:order) { FactoryBot.create(:order, :in_cart, user_email: 'random_mail@email.com') }
        let!(:user) { order.user }
        before { request.session[:user_id] = user.id }
        before { patch :cancel, params: { invoice_number: order.invoice_number } }
        it { expect(response).to redirect_to(order_path(order)) }
        it { expect(request.flash.alert).to eql("Cannot transition state via :cancel from :cart (Reason(s): State cannot transition via \"cancel\")") }
      end

      context 'order cancelled successfully' do
        let!(:order) { FactoryBot.create(:order, :in_cart, user_email: 'random_mail@email.com') }
        let!(:user) { order.user }
        before { request.session[:user_id] = user.id }
        before { allow_any_instance_of(Order).to receive(:cancelled_by!).and_return(true) }
        before { patch :cancel, params: { invoice_number: order.invoice_number } }
        it { expect(response).to redirect_to(order_path(order)) }
        it { expect(request.flash.notice).to eql(I18n.t(:order_successfully_cancelled, scope: [:flash, :notice])) }
      end

    end

    context 'when logged out' do
      before { patch :cancel, params: { invoice_number: 'INV-random_token' } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }      
    end
  end
end
