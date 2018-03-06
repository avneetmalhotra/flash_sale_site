require "rails_helper"

RSpec.describe ConfirmationsController, type: :controller do
  it { expect(controller.class.ancestors).to include(ApplicationController) }

  it { is_expected.to use_before_action(:ensure_logged_out) }
  it { is_expected.to use_before_action(:fetch_user) }
  it { is_expected.to use_before_action(:fetch_user_from_confirmation_token) }
  it { is_expected.to use_before_action(:ensure_not_confirmed) }
  it { is_expected.to use_before_action(:ensure_confirmation_token_validity) }

  describe 'GET #new' do
   context 'when user logged in' do
      let!(:user) { FactoryBot.create(:user) }
      before { request.session[:user_id] = user.id }
      before { get :new }
      context 'fails' do
        it { expect(response).to redirect_to(root_path) }
        it { expect(flash[:alert]).to eql(I18n.t(:logout_to_continue, scope: [:flash, :alert])) }
      end
    end

    context 'when no user logged in' do
      before { get :new }
      it { expect(response.status).to eq 200 }
      it { expect(response).to render_template(:new) }
    end
  end

  describe 'POST #create' do
   context 'when user logged in' do
      let!(:user) { FactoryBot.create(:user) }
      before { request.session[:user_id] = user.id }
      before { post :create }
      context 'fails' do
        it { expect(response).to redirect_to(root_path) }
        it { expect(flash[:alert]).to eql(I18n.t(:logout_to_continue, scope: [:flash, :alert])) }
      end
    end

    context 'when no user logged in' do
      context 'failure' do
        let!(:user) { FactoryBot.create(:user, :confirmed) }
        context 'due to invalid user' do
          before { post :create, params: { email: 'invalid_email@mail.com' } }
          it { expect(response).to redirect_to(new_confirmation_path) }
          it { expect(flash[:alert]).to eql(I18n.t(:invalid_account, scope: [:flash, :alert])) }
        end

        context 'if user is already confirmed' do
          before { post :create, params: { email: user.email } }
          it { expect(response).to redirect_to(login_path) }
          it { expect(flash[:alert]).to eql(I18n.t(:account_already_confirmed, scope: [:flash, :alert])) }
        end
      end

      context 'success' do
        let!(:user) { FactoryBot.create(:user) }
        before { post :create, params: { email: user.email } }
        it { expect(user.confirmation_token).to be_present }
        it { expect(response).to redirect_to(login_path) }
        it { expect(flash[:notice]).to eql(I18n.t(:confirmation_email_sent, scope: [:flash, :notice])) }
      end
    end
  end

  describe 'GET #confirm' do
   context 'when user logged in' do
      let!(:user) { FactoryBot.create(:user) }
      before { request.session[:user_id] = user.id }
      before { get :confirm }
      context 'fails' do
        it { expect(response).to redirect_to(root_path) }
        it { expect(flash[:alert]).to eql(I18n.t(:logout_to_continue, scope: [:flash, :alert])) }
      end
    end

    context 'when no user logged in' do
      context 'failure' do
        context 'invalid user' do
          before { get :confirm, params: { confirmation_token: 'invalid_token' } }
          it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
          it { expect(response.status).to eq(404) }
        end
        context 'if user is already confirmed' do
          let!(:user) { FactoryBot.create(:user, :confirmed, :with_confirmation_token) }
          before { get :confirm, params: { confirmation_token: user.confirmation_token } }
          it { expect(response).to redirect_to(login_path) }
          it { expect(flash[:alert]).to eql(I18n.t(:account_already_confirmed, scope: [:flash, :alert])) }
        end
        context 'if confirmation_token has expired' do
          let!(:user) { FactoryBot.create(:user, :with_confirmation_token) }
          before { allow_any_instance_of(User).to receive(:confirmation_token_expired?).and_return(true) }
          before { get :confirm, params: { confirmation_token: user.confirmation_token } }
          it { expect(response).to redirect_to(login_path) }
          it { expect(flash[:alert]).to eql(I18n.t(:invalid_confirmation_token, scope: [:flash, :alert])) }
        end
      end

      context 'success' do
        let!(:user) { FactoryBot.create(:user, :with_confirmation_token) }
        before { allow_any_instance_of(User).to receive(:confirmation_token_expired?).and_return(false) }
        before { get :confirm, params: { confirmation_token: user.confirmation_token } }
        it { expect(assigns(:user).confirmed_at).to be_present }
        it { expect(response).to redirect_to(login_path) }
        it { expect(flash[:notice]).to eql(I18n.t(:account_confirmed, scope: [:flash, :notice])) }
      end
    end
  end

end
