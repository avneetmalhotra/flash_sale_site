require "rails_helper"

RSpec.describe AddressesController, type: :controller do
  it { expect(AddressesController.ancestors).to include(ApplicationController) }

  it { is_expected.to use_before_action(:ensure_current_order_present) }
  it { is_expected.to use_before_action(:ensure_checkout_allowed) }
  it { is_expected.to use_before_action(:update_current_order_state) }
  it { is_expected.to use_before_action(:get_current_user_associated_addresses) }
  it { is_expected.to use_before_action(:get_address) }

  describe 'GET #new' do
    context 'when logged in' do

      context 'fails' do
        context 'due to current order absence' do
          let!(:user) { FactoryBot.create(:user) }
          before { request.session[:user_id] = user.id }
          before { get :new }
          it { expect(response).to redirect_to(cart_path) }
          it { expect(request.flash.alert).to eql(I18n.t(:cart_empty, scope: [:flash, :alert])) }
        end

        context 'when checkout not allowed' do
          let!(:current_order) { FactoryBot.create(:order) }
          let!(:user) { current_order.user }
          before { request.session[:user_id] = user.id }
          before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(false) }
          before { get :new }
          it { expect(response).to redirect_to(cart_path) }
          it { expect(request.flash.alert).to eql(current_order.pretty_errors) }
        end

        context 'when state updation fails' do
          let!(:current_order) { FactoryBot.create(:order) }
          let!(:user) { current_order.user }
          before { request.session[:user_id] = user.id }
          before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(true) }
          before { allow(controller.send(:current_order)).to receive(:can_add_address?).and_return(true) }
          before { allow(controller.send(:current_order)).to receive(:add_address).and_return(false) }
          before { get :new }
          it { expect(response).to redirect_to(cart_path) }
          it { expect(request.flash.alert).to eql(current_order.pretty_errors) }
        end
      end

      context 'successful when initailizes new address' do
        let!(:current_order) { FactoryBot.create(:order) }
        let!(:user) { current_order.user }
        let!(:user_address1) { FactoryBot.create(:address, user_id: user.id) }
        before { request.session[:user_id] = user.id }
        before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(true) }
        before { allow(controller.send(:current_order)).to receive(:can_add_address?).and_return(true) }
        before { allow(controller.send(:current_order)).to receive(:add_address).and_return(true) }
        before { get :new }
        it { expect(assigns(:addresses)).to include(user_address1) }
        it { expect(assigns(:address)).to be_a_new(Address) }
        it { expect(response).to render_template(:new) }
      end
    end

    context 'when logged out' do
      before { get :new }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }      
    end
  end

  describe 'POST #create' do
    context 'when logged in' do

      context 'fails' do
        context 'due to current order absence' do
          let!(:user) { FactoryBot.create(:user) }
          before { request.session[:user_id] = user.id }
          before { post :create, params: { address: {} } }
          it { expect(response).to redirect_to(cart_path) }
          it { expect(request.flash.alert).to eql(I18n.t(:cart_empty, scope: [:flash, :alert])) }
        end

        context 'when checkout not allowed' do
          let!(:current_order) { FactoryBot.create(:order) }
          let!(:user) { current_order.user }
          before { request.session[:user_id] = user.id }
          before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(false) }
          before { post :create }
          it { expect(response).to redirect_to(cart_path) }
          it { expect(request.flash.alert).to eql(current_order.pretty_errors) }
        end

        context 'due to invalid address creation' do
          let!(:current_order) { FactoryBot.create(:order) }
          let!(:user) { current_order.user }
          before { request.session[:user_id] = user.id }
          before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(true) }
          before { allow(controller.send(:current_order)).to receive(:can_add_address?).and_return(true) }
          before { post :create, params: { address: { house_number: '' } } }
          it { expect(response).to render_template(:new) }
        end

        context 'due to current_order assocation failure' do
          let!(:current_order) { FactoryBot.create(:order) }
          let!(:user) { current_order.user }
          before { request.session[:user_id] = user.id }
          before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(true) }
          before { allow(controller.send(:current_order)).to receive(:can_add_address?).and_return(true) }
          before { allow_any_instance_of(Address).to receive(:save).and_return(true) }
          before { allow(controller.send(:current_order)).to receive(:associate_address).and_return(false) }
          before { post :create, params: { address: { house_number: '' } } }
          it { expect(response).to redirect_to(new_address_path) }
          it { expect(request.flash.alert).to eql(current_order.pretty_errors) }
        end
      end

      context 'successful' do
          let!(:current_order) { FactoryBot.create(:order) }
          let!(:user) { current_order.user }
          before { request.session[:user_id] = user.id }
          before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(true) }
          before { allow(controller.send(:current_order)).to receive(:can_add_address?).and_return(true) }
          before { post :create, params: { address: { 
                                            house_number: 'hno', 
                                            street: 'street',
                                            city: 'city',
                                            state: 'state',
                                            country: 'country',
                                            pincode: 111 
                                            } 
                                          } 
                  }
          it { expect(response).to redirect_to(new_payment_path) }
          it { expect(request.flash.notice).to eql(I18n.t(:address_successfully_added, scope: [:flash, :notice])) }
          it { expect(controller.send(:address_params).permitted?).to be true }
          it { expect(controller.send(:address_params)).to include(:house_number, :street, :city, :state, :country, :pincode) }
      end
    end

    context 'when logged out' do
      before { get :new }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }      
    end
  end

  describe 'PATCH #associate_address' do
    context 'when logged in' do

      context 'fails' do
        context 'due to current order absence' do
          let!(:user) { FactoryBot.create(:user) }
          before { request.session[:user_id] = user.id }
          before { patch :associate_address, params: { current_user: { recently_used_address_id: 0 } } }
          it { expect(response).to redirect_to(cart_path) }
          it { expect(request.flash.alert).to eql(I18n.t(:cart_empty, scope: [:flash, :alert])) }
        end

        context 'when checkout not allowed' do
          let!(:current_order) { FactoryBot.create(:order) }
          let!(:user) { current_order.user }
          before { request.session[:user_id] = user.id }
          before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(false) }
          before { patch :associate_address, params: { current_user: { recently_used_address_id: 0 } } }
          it { expect(response).to redirect_to(cart_path) }
          it { expect(request.flash.alert).to eql(current_order.pretty_errors) }
        end

        context 'due to invalid address' do
          let!(:current_order) { FactoryBot.create(:order) }
          let!(:user) { current_order.user }
          before { request.session[:user_id] = user.id }
          before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(true) }
          before { patch :associate_address, params: { current_user: { recently_used_address_id: 0 } } }
          it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
          it { expect(response.status).to eq(404) }
        end

        context 'due to current user and address association failure' do
          let!(:current_order) { FactoryBot.create(:order) }
          let!(:user) { current_order.user }
          before { request.session[:user_id] = user.id }
          before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(true) }
          before { allow(assigns(:address)).to receive(:present?).and_return(true) }
          before { allow(controller.send(:current_order)).to receive(:associate_address).and_return(false) }
          before { patch :associate_address, params: { current_user: { recently_used_address_id: 4 } } }
          it { expect(response).to redirect_to(new_address_path) }
          it { expect(request.flash.alert).to eql(current_order.pretty_errors) }
        end
      end

      context 'successful' do
        let!(:current_order) { FactoryBot.create(:order) }
        let!(:user) { current_order.user }
        before { request.session[:user_id] = user.id }
        before { allow(controller.send(:current_order)).to receive(:checkout_allowed?).and_return(true) }
        before { allow(assigns(:address)).to receive(:present?).and_return(true) }
        before { allow(controller.send(:current_order)).to receive(:associate_address).and_return(true) }
        before { patch :associate_address, params: { current_user: { recently_used_address_id: 4 } } }
        it { expect(response).to redirect_to(new_payment_path) }
        it { expect(request.flash.notice).to eql(I18n.t(:address_successfully_added, scope: [:flash, :notice])) }
      end
    end

    context 'when logged out' do
      before { get :new }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }      
    end
  end

end
