require "rails_helper"

RSpec.describe LineItemsController, type: :controller do
  
  it { expect(LineItemsController.ancestors).to include(ApplicationController) }

  it { is_expected.to use_before_action(:get_order) }
  it { is_expected.to use_before_action(:get_line_item) }

  describe 'GET #create' do
    context 'when user logged in' do
      let!(:user) { FactoryBot.create(:user) }
      let!(:deal) { FactoryBot.create(:deal) }
      let(:live_deal) { FactoryBot.create(:deal, title: 'random new title') }
      before do
        request.session[:user_id] = user.id
      end
      
      context 'fails for invalid deal' do
        before { get :create, params: { deal_id: deal.id + 2 } }
        it { expect(response).to redirect_to(root_path) }
        it { expect(request.flash.alert).to eql(I18n.t(:deal_cannot_be_added_to_cart, scope: [:flash, :alert])) }
      end

      context 'line_item creation fails' do
        before { get :create, params: { deal_id: deal.id, line_item: { quantity: 2 } } }
        it { expect(response).to redirect_to(deal_path(deal)) }
        it { expect(request.flash.alert).to eql(assigns(:line_item).pretty_errors) }
      end

      context 'line_item created successfully' do
        before do
          live_deal.update_columns(publishing_date: Date.current, start_at: Time.current, end_at: 1.day.after)
          get :create, params: { deal_id: live_deal.id, line_item: { quantity: 1 } }
        end
        it { expect(response).to redirect_to(cart_path) }
        it { expect(request.flash.notice).to eql(I18n.t(:deal_added_to_cart, scope: [:flash, :notice], deal_title: live_deal.title)) }
      end
    end

    context 'when logged out' do
      before { get :create }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }      
    end
  end

  describe 'DELETE #destroy' do
    context 'when user logged in' do
      let!(:user) { FactoryBot.create(:user, email: 'random_new_emal@mail.com') }
      let!(:line_item) { FactoryBot.create(:line_item) }
      before do
        request.session[:user_id] = user.id
      end
      
      context 'fails for invalid line_item' do
        before { delete :destroy, params: { id: line_item.id + 1 } }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
        it { expect(response.status).to eq(404) }
      end

      context 'line_item destruction fails' do
        before { allow_any_instance_of(LineItem).to receive(:destroy).and_return(false) }
        before { delete :destroy, params: { id: line_item } }
        it { expect(response).to redirect_to(cart_path) }
        it { expect(request.flash.alert).to eql(assigns(:line_item).pretty_errors) }
      end

      context 'line_item destroyed successfully' do
        before { allow_any_instance_of(LineItem).to receive(:destroy).and_return(true) }
        before { delete :destroy, params: { id: line_item } }
        it { expect(response).to redirect_to(cart_path) }
        it { expect(request.flash.notice).to eql(I18n.t(:deal_deleted_from_cart, scope: [:flash, :notice], deal_title: line_item.deal.title)) }
      end
    end

    context 'when logged out' do
      before { delete :destroy, params: { id: 0 } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }      
    end
  end

  describe 'PATCH #update' do
    context 'when user logged in' do
      let!(:user) { FactoryBot.create(:user, email: 'some_random_mail@email.com') }
      let!(:line_item) { FactoryBot.create(:line_item) }
      before do
        request.session[:user_id] = user.id
      end
      
      context 'fails for invalid line_item' do
        before { patch :update, params: { id: line_item.id + 1 } }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
        it { expect(response.status).to eq(404) }
      end

      context 'line_item updation fails' do
        before { allow_any_instance_of(LineItem).to receive(:update).and_return(false) }
        before { patch :update, params: { id: line_item, line_item: { quantity: 5 } } }
        it { expect(response).to redirect_to(cart_path) }
        it { expect(request.flash.alert).to eql(assigns(:line_item).pretty_errors) }
      end

      context 'line_item updated successfully' do
        before { allow_any_instance_of(LineItem).to receive(:update).and_return(true) }
        before { patch :update, params: { id: line_item, line_item: { quantity: 1 } } }
        it { expect(response).to redirect_to(cart_path) }
        it { expect(request.flash.notice).to eql(I18n.t(:line_item_quantity_updated, scope: [:flash, :notice], scope: [:flash, :notice], deal_title: line_item.deal.title)) }
      end
    end

    context 'when logged out' do
      before { patch :update, params: { id: 3 } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }      
    end
  end
end
