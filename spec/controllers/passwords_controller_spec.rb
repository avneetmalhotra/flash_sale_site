require "rails_helper"

RSpec.describe PasswordsController, type: :controller do
  it { expect(controller.class.ancestors).to include(ApplicationController) }

  it { is_expected.to use_before_action(:ensure_logged_out) }
  it { is_expected.to use_before_action(:fetch_user) }
  it { is_expected.to use_before_action(:fetch_user_from_password_reset_token) }
  it { is_expected.to use_before_action(:ensure_password_reset_token_validity) }

  describe 'GET #new' do
    context 'when user is logged in' do
      let!(:user) { FactoryBot.create(:user) }
      before { request.session[:user_id] = user.id }
      before { get :new }
      context 'fails' do
        it { expect(response).to redirect_to(root_path) }
        it { expect(flash[:alert]).to eql(I18n.t(:logout_to_continue, scope: [:flash, :alert])) }
      end
    end

    context 'when no user is logged in' do
      before { get :new }
      it { expect(response).to render_template(:new) }
    end
  end

  describe 'POST #create' do
    context 'when user is logged in' do
      let!(:user) { FactoryBot.create(:user) }
      before { request.session[:user_id] = user.id }
      before { post :create }
      context 'fails' do
        it { expect(response).to redirect_to(root_path) }
        it { expect(flash[:alert]).to eql(I18n.t(:logout_to_continue, scope: [:flash, :alert])) }
      end
    end

    context 'when no user is logged in' do
      context 'failure' do
        context 'due to invalid email' do
          before { post :create, params: { email: 'invalid_email@mail.com' } }
          it { expect(response).to redirect_to(new_password_path) }
          it { expect(flash[:alert]).to eql(I18n.t(:invalid_account, scope: [:flash, :alert])) }
        end
      end

      context 'success' do
        let!(:user) { FactoryBot.create(:user) }
        before { allow_any_instance_of(User).to receive(:send_password_reset_instructions) }
        before { post :create, params: { email: user.email } }
        it { expect(response).to redirect_to(login_path) }
        it { expect(flash[:notice]).to eql(I18n.t(:password_reset_email_sent, scope: [:flash, :notice])) }
      end
      
    end
  end

  describe 'GET #edit' do
    context 'when user is logged in' do
      let!(:user) { FactoryBot.create(:user) }
      before { request.session[:user_id] = user.id }
      before { get :edit }
      context 'fails' do
        it { expect(response).to redirect_to(root_path) }
        it { expect(flash[:alert]).to eql(I18n.t(:logout_to_continue, scope: [:flash, :alert])) }
      end
    end

    context 'when no user is logged in' do
      context 'failure' do
        context 'due to invalid user' do
          before { get :edit, params: { password_reset_token: 'invalid_token' } }
          it { expect(response.status).to eq(404) }
          it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
        end

        context 'when password_reset_token has expired' do
          let!(:user) { FactoryBot.create(:user) }
          before { user.update_columns(password_reset_token: 'password_reset_token') }
          before { allow_any_instance_of(User).to receive(:password_reset_token_expired?).and_return(true) }
          before { get :edit, params: { password_reset_token: user.password_reset_token } }
          it { expect(response).to redirect_to(login_path) }
          it { expect(flash[:alert]).to eql(I18n.t(:invalid_password_reset_token, scope: [:flash, :alert])) }
        end
      end

      context 'success' do
        let!(:user) { FactoryBot.create(:user) }
        before { user.update_columns(password_reset_token: 'password_reset_token') }
        before { allow_any_instance_of(User).to receive(:password_reset_token_expired?).and_return(false) }
        before { get :edit, params: { password_reset_token: user.password_reset_token } }
        it { expect(response).to render_template(:edit) }
      end
    end
  end

  describe 'PATCH #update' do
    context 'when user is logged in' do
      let!(:user) { FactoryBot.create(:user) }
      before { request.session[:user_id] = user.id }
      before { patch :update }
      context 'fails' do
        it { expect(response).to redirect_to(root_path) }
        it { expect(flash[:alert]).to eql(I18n.t(:logout_to_continue, scope: [:flash, :alert])) }
      end
    end

    context 'when no user is logged in' do
      context 'failure' do
        context 'due to invalid user' do
          before { patch :update, params: { password_reset_token: 'invalid_token' } }
          it { expect(response.status).to eq(404) }
          it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
        end

        context 'when password_reset_token has expired' do
          let!(:user) { FactoryBot.create(:user) }
          before { user.update_columns(password_reset_token: 'password_reset_token') }
          before { allow_any_instance_of(User).to receive(:password_reset_token_expired?).and_return(true) }
          before { patch :update, params: { password_reset_token: user.password_reset_token } }
          it { expect(response).to redirect_to(login_path) }
          it { expect(flash[:alert]).to eql(I18n.t(:invalid_password_reset_token, scope: [:flash, :alert])) }
        end

        context 'invalid password update update params' do
          let!(:user) { FactoryBot.create(:user) }
          before { user.update_columns(password_reset_token: 'password_reset_token') }
          before { allow_any_instance_of(User).to receive(:password_reset_token_expired?).and_return(false) }
          before { patch :update, params: { password_reset_token: user.password_reset_token, user: { password: 'pass', password_confirmation: 'wrong_pass' } } }
          it { expect(response).to render_template(:edit) }
        end
      end

      context 'success' do
        let!(:user) { FactoryBot.create(:user) }
        before { user.update_columns(password_reset_token: 'password_reset_token') }
        before { allow_any_instance_of(User).to receive(:password_reset_token_expired?).and_return(false) }
        before { patch :update, params: { password_reset_token: user.password_reset_token, user: { password: 'new_password', password_confirmation: 'new_password' } } }
        it { expect(response).to redirect_to(login_path) }
        it { expect(flash[:notice]).to eql(I18n.t(:password_successfully_reset, scope: [:flash, :notice])) }
      end
    end
  end
end
