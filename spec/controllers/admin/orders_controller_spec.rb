require "rails_helper"

RSpec.describe Admin::OrdersController, type: :controller do
  it { expect(controller.class.ancestors).to include(ApplicationController) }
  
  it { is_expected.to use_before_action(:fetch_orders) }
  it { is_expected.to use_before_action(:get_order) }

  describe 'GET #index' do
    context 'when user logged in' do
      context 'when user is admin' do
        let!(:user) { FactoryBot.create(:user, :admin) }
        before { request.session[:user_id] = user.id }
        context 'get all orders' do
          let!(:order_ready_for_delivery) { FactoryBot.create(:order, :completed, user_email: 'one@mail.com') }
          let!(:delivered_order) { FactoryBot.create(:order, :delivered, user_email: 'two@mail.com') }
          let!(:cancelled_order) { FactoryBot.create(:order, :cancelled, user_email: 'three@mail.com') }
          before { get :index }
          it { expect(assigns(:orders)).to include(order_ready_for_delivery, delivered_order, cancelled_order) }
          it { expect(assigns(:orders).count).to eql 3 }
          it { expect(assigns(:ready_for_delivery_orders)).to include(order_ready_for_delivery) }
          it { expect(assigns(:ready_for_delivery_orders).count).to eql 1 }
          it { expect(assigns(:delivered_orders)).to include(delivered_order) }
          it { expect(assigns(:delivered_orders).count).to eql 1 }
          it { expect(assigns(:cancelled_orders)).to include(cancelled_order) }
          it { expect(assigns(:cancelled_orders).count).to eql 1 }
        end

        context 'search orders by email' do
          let!(:order_ready_for_delivery) { FactoryBot.create(:order, :completed, user_email: 'one@mail.com') }
          let!(:delivered_order) { FactoryBot.create(:order, :delivered, user_email: 'two@mail.com') }
          let!(:cancelled_order) { FactoryBot.create(:order, :cancelled, user_email: 'three@mail.com') }
          before { get :index, params: { search: { email: 'mail.com' } } }
          it { expect(assigns(:orders)).to include(order_ready_for_delivery, delivered_order, cancelled_order) }
          it { expect(assigns(:orders).count).to eql 3 }
          it { expect(assigns(:ready_for_delivery_orders)).to include(order_ready_for_delivery) }
          it { expect(assigns(:ready_for_delivery_orders).count).to eql 1 }
          it { expect(assigns(:delivered_orders)).to include(delivered_order) }
          it { expect(assigns(:delivered_orders).count).to eql 1 }
          it { expect(assigns(:cancelled_orders)).to include(cancelled_order) }
          it { expect(assigns(:cancelled_orders).count).to eql 1 }
        end
      end

      context 'when user is not admin' do
        let!(:user) { FactoryBot.create(:user) }
        before do
          request.session[:user_id] = user.id
          get :index
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end
    end

    context 'when no user logged in' do
      before { get :index }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

  describe 'GET #show' do
    context 'when user logged in' do
      context 'when user is admin' do
        let!(:user) { FactoryBot.create(:user, :admin) }
        before { request.session[:user_id] = user.id }
        context 'failure' do
          context 'due to invalid order' do
            before { get :show, params: { invoice_number: 'invalid' } }
            it { expect(response.status).to eq(404) }
            it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
          end
        end

        context 'success' do
          let!(:order) { FactoryBot.create(:order, :cancelled, user_email: 'three@mail.com') }
          before { get :show, params: { invoice_number: order.invoice_number } }
          it { expect(response).to render_template(:show) }
        end
      end

      context 'when user is not admin' do
        let!(:user) { FactoryBot.create(:user) }
        before do
          request.session[:user_id] = user.id
          get :show, params: { invoice_number: 'random' }
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end
    end

    context 'when no user logged in' do
      before { get :show, params: { invoice_number: 'random' } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

  describe 'PATCH #cancel' do
    context 'when user logged in' do
      context 'when user is admin' do
        let!(:user) { FactoryBot.create(:user, :admin) }
        before { request.session[:user_id] = user.id }
        context 'failure' do
          context 'due to invalid order' do
            before { patch :cancel, params: { invoice_number: 'invalid' } }
            it { expect(response.status).to eq(404) }
            it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
          end

          context 'due to exception at cancellation' do
            let!(:order) { FactoryBot.create(:order, :cancelled, user_email: 'three@mail.com') }
            before { allow_any_instance_of(Order).to receive(:cancelled_by!).and_raise('error_message') }
            before { patch :cancel, params: { invoice_number: order.invoice_number } }
            it { expect(response).to redirect_to(admin_order_path(order)) }
            it { expect(request.flash.alert).to eql('error_message') }
          end
        end

        context 'success' do
          let!(:order) { FactoryBot.create(:order, :cancelled, user_email: 'three@mail.com') }
          before { allow_any_instance_of(Order).to receive(:cancelled_by!).and_return(true) }
          before { patch :cancel, params: { invoice_number: order.invoice_number } }
          it { expect(response).to redirect_to(admin_order_path(order)) }
          it { expect(request.flash.notice).to eql(I18n.t(:order_successfully_cancelled, scope: [:flash, :notice])) }
        end
      end

      context 'when user is not admin' do
        let!(:user) { FactoryBot.create(:user) }
        before do
          request.session[:user_id] = user.id
          patch :cancel, params: { invoice_number: 'random' }
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end
    end

    context 'when no user logged in' do
      before { patch :cancel, params: { invoice_number: 'random' } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

  describe 'PATCH #deliver' do
    context 'when user logged in' do
      context 'when user is admin' do
        let!(:user) { FactoryBot.create(:user, :admin) }
        before { request.session[:user_id] = user.id }
        context 'failure' do
          context 'due to invalid order' do
            before { patch :deliver, params: { invoice_number: 'invalid' } }
            it { expect(response.status).to eq(404) }
            it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
          end

          context 'due to exception at delivery' do
            let!(:order) { FactoryBot.create(:order, :cancelled, user_email: 'three@mail.com') }
            before { allow_any_instance_of(Order).to receive(:deliver).and_return(false) }
            before { allow_any_instance_of(Order).to receive(:pretty_errors).and_return('pretty errors') }
            before { patch :deliver, params: { invoice_number: order.invoice_number } }
            it { expect(response).to redirect_to(admin_order_path(order)) }
            it { expect(assigns(:order).pretty_errors).to eql('pretty errors') }
          end
        end

        context 'success' do
          let!(:order) { FactoryBot.create(:order, :completed, user_email: 'three@mail.com') }
          before { patch :deliver, params: { invoice_number: order.invoice_number } }
          it { expect(response).to redirect_to(admin_order_path(order)) }
          it { expect(request.flash.notice).to eql(I18n.t(:order_successfully_marked_delivered, scope: [:flash, :notice])) }
        end
      end

      context 'when user is not admin' do
        let!(:user) { FactoryBot.create(:user) }
        before do
          request.session[:user_id] = user.id
          patch :deliver, params: { invoice_number: 'random' }
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end
    end

    context 'when no user logged in' do
      before { patch :deliver, params: { invoice_number: 'random' } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end
end
