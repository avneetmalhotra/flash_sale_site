require "rails_helper"

RSpec.describe PaymentsController, type: :controller do
  it { expect(controller.class.ancestors).to include(ApplicationController) }

  it { is_expected.to use_before_action(:ensure_current_order_present) }
  it { is_expected.to use_before_action(:ensure_checkout_allowed) }
  it { is_expected.to use_before_action(:update_current_order_state) }

  describe 'GET #new' do
    context 'when user logged in' do
      context 'fails' do
        context 'due to current order absence' do
          let!(:user) { FactoryBot.create(:user) }
          before { request.session[:user_id] = user.id }
          before { get :new }
          it { expect(response).to redirect_to(cart_path) }
          it { expect(flash[:alert]).to eql(I18n.t(:cart_empty, scope: [:flash, :alert])) }
        end

        context 'when checkout not allowed' do
          let!(:current_order) { FactoryBot.create(:order) }
          let!(:user) { current_order.user }
          before { request.session[:user_id] = user.id }
          before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(false) }
          before { get :new }
          it { expect(response).to redirect_to(cart_path) }
          it { expect(flash[:alert]).to eql(current_order.pretty_errors) }
        end

        context 'when state not updated' do
          let!(:current_order) { FactoryBot.create(:order, :in_cart) }
          let!(:user) { current_order.user }
          before { request.session[:user_id] = user.id }
          before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(true) }

          context 'due to state being cart' do
            before { get :new }
            it { expect(response).to redirect_to(cart_path) }
            it { expect(flash[:alert]).to eq(I18n.t(:address_not_added, scope: [:flash, :alert])) }
          end

          context 'state transition failure' do
            before { allow(controller.send(:current_order)).to receive(:cart?).and_return(false) }
            before { allow(controller.send(:current_order)).to receive(:can_pay?).and_return(true) }
            before { allow(controller.send(:current_order)).to receive(:pay).and_return(false) }
            before { get :new }
            it { expect(response).to redirect_to(cart_path) }
            it { expect(flash[:alert]).to eq(assigns(:current_order).pretty_errors) }
          end
        end
      end

      context 'successful' do
        let!(:current_order) { FactoryBot.create(:order, :in_cart) }
        let!(:user) { current_order.user }
        before { request.session[:user_id] = user.id }
        before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(true) }
        before { allow(controller.send(:current_order)).to receive(:cart?).and_return(false) }
        before { allow(controller.send(:current_order)).to receive(:can_pay?).and_return(true) }
        before { allow(controller.send(:current_order)).to receive(:pay).and_return(true) }
        before { get :new }
        it { expect(response).to render_template(:new) }
      end
    end

    context 'when user logged out' do
      before { get :new }
      it { expect(response).to redirect_to(login_path) }
      it { expect(flash[:alert]).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }      
    end
  end

  describe 'POST #create' do
    context 'when user logged in' do
      context 'fails' do
        context 'due to current order absence' do
          let!(:user) { FactoryBot.create(:user) }
          before { request.session[:user_id] = user.id }
          before { post :create }
          it { expect(response).to redirect_to(cart_path) }
          it { expect(flash[:alert]).to eql(I18n.t(:cart_empty, scope: [:flash, :alert])) }
        end

        context 'when checkout not allowed' do
          let!(:current_order) { FactoryBot.create(:order) }
          let!(:user) { current_order.user }
          before { request.session[:user_id] = user.id }
          before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(false) }
          before { post :create }
          it { expect(response).to redirect_to(cart_path) }
          it { expect(flash[:alert]).to eql(current_order.pretty_errors) }
        end

        context 'when state not updated' do
          let!(:current_order) { FactoryBot.create(:order, :in_cart) }
          let!(:user) { current_order.user }
          before { request.session[:user_id] = user.id }
          before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(true) }

          context 'due to state being cart' do
            before { post :create }
            it { expect(response).to redirect_to(cart_path) }
            it { expect(flash[:alert]).to eq(I18n.t(:address_not_added, scope: [:flash, :alert])) }
          end

          context 'state transition failure' do
            before { allow(controller.send(:current_order)).to receive(:cart?).and_return(false) }
            before { allow(controller.send(:current_order)).to receive(:can_pay?).and_return(true) }
            before { allow(controller.send(:current_order)).to receive(:pay).and_return(false) }
            before { post :create }
            it { expect(response).to redirect_to(cart_path) }
            it { expect(flash[:alert]).to eq(assigns(:current_order).pretty_errors) }
          end            
        end

        context 'due to exception' do
          let!(:current_order) { FactoryBot.create(:order, :in_cart) }
          let!(:user) { current_order.user }
          before { request.session[:user_id] = user.id }
          before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(true) }
          before { allow(controller.send(:current_order)).to receive(:cart?).and_return(false) }
          before { allow(controller.send(:current_order)).to receive(:can_pay?).and_return(true) }
          before { allow(controller.send(:current_order)).to receive(:pay).and_return(true) }

          context 'handle exception' do
            before { allow_any_instance_of(Payment).to receive(:create_stripe_record!).and_raise('abc') }
            before { post :create, params: { stripeToken: 'stripe-token' } }
            it { expect(response).to redirect_to(new_payment_path) }
            it { expect(flash[:alert]).to eq('abc') }
          end
        end
      end

      context 'successful' do
          let!(:current_order) { FactoryBot.create(:order, :in_cart) }
          let!(:user) { current_order.user }
          let!(:payment) { FactoryBot.create(:payment, :with_order_id, order_id: current_order.id) }
          before { request.session[:user_id] = user.id }
          before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(true) }
          before { allow(controller.send(:current_order)).to receive(:cart?).and_return(false) }
          before { allow(controller.send(:current_order)).to receive(:can_pay?).and_return(true) }
          before { allow(controller.send(:current_order)).to receive(:pay).and_return(true) }
          before { allow_any_instance_of(Payment).to receive(:create_stripe_record!).and_return(true) }
          before { post :create, params: { stripeToken: 'stripe-token' } }
          before { assigns[:payment] =  payment }
          it { expect(response).to redirect_to(order_path(assigns(:payment).order)) }
          it { expect(flash[:notice]).to eql(I18n.t(:order_placed_successfully, scope: [:flash, :notice])) }
      end
    end

    context 'when user logged out' do
      before { post :create }
      it { expect(response).to redirect_to(login_path) }
      it { expect(flash[:alert]).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }      
    end
  end


end
