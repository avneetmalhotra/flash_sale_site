require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  it { expect(controller.class.ancestors).to include(ApplicationController) }
  it { expect(controller.class.ancestors).to include(Controllers::Rememberable) }

  it { is_expected.to use_before_action(:ensure_logged_out) }
  it { is_expected.to use_before_action(:fetch_user) }
  it { is_expected.to use_before_action(:ensure_user_confirmed) }
  it { is_expected.to use_before_action(:ensure_user_active) }

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
      context 'successful' do
        before { get :new }
        it { expect(response).to render_template(:new) }
      end
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
      context 'fails' do
        context 'for invalid user' do
          before { post :create, params: { user: { email: 'invalid@mail.com' } } }
          it { expect(response).to redirect_to(login_path) }
          it { expect(flash[:alert]).to eql(I18n.t(:invalid_email_or_password, scope: [:flash, :alert])) }
        end

        context 'for unconfirmed user' do
          let!(:user) { FactoryBot.create(:user) }
          before { post :create, params: { user: { email: user.email } } }
          it { expect(response).to redirect_to(login_path) }
          it { expect(flash[:alert]).to eql(I18n.t(:account_not_confirmed, scope: [:flash, :alert])) }
        end

        context 'for inactive user' do
          let!(:user) { FactoryBot.create(:user, :confirmed, :inactive) }
          before { post :create, params: { user: { email: user.email } } }
          it { expect(response).to redirect_to(login_path) }
          it { expect(flash[:alert]).to eql(I18n.t(:account_inactive, scope: [:flash, :alert])) }
        end

        context 'for wrong password' do
          let!(:user) { FactoryBot.create(:user, :confirmed, :active) }
          before { post :create, params: { user: { email: user.email, password: 'wrong_password' } } }
          it { expect(response).to redirect_to(login_path) }
          it { expect(flash[:alert]).to eql(I18n.t(:invalid_email_or_password, scope: [:flash, :alert])) }
        end
      end

      context 'successful' do
        # context 'with remember be selected' do
        #   let!(:user) { FactoryBot.create(:user, :confirmed, :active) }
        #   before { post :create, params: { user: { email: user.email, password: 'password' }, remember_me: '1' } }
          # it { expect(response.cookies.encrypted[:remember_me]) }
        #   it { debugger }
        #   it { expect(response).to redirect_to(login_path) }
        #   it { expect(flash[:alert]).to eql(I18n.t(:invalid_email_or_password, scope: [:flash, :alert])) }
        # end

        context 'without remember be selected' do
          context 'for admin user' do
            let!(:user) { FactoryBot.create(:user, :confirmed, :active, :admin) }
            before { post :create, params: { user: { email: user.email, password: 'password' } } }
            it { expect(response).to redirect_to(admin_deals_path) }
            it { expect(flash[:notice]).to eql(I18n.t(:login_successfull, scope: [:flash, :notice])) }
          end
          context 'for non-admin user' do
            let!(:user) { FactoryBot.create(:user, :confirmed, :active) }
            before { post :create, params: { user: { email: user.email, password: 'password' } } }
            it { expect(response).to redirect_to(root_path) }
            it { expect(flash[:notice]).to eql(I18n.t(:login_successfull, scope: [:flash, :notice])) }
          end
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user logged in' do
      let!(:user) { FactoryBot.create(:user, :confirmed, :active) }
      before { request.session[:user_id] = user.id }
      before { delete :destroy }
      it do
        expect(session.count).to eq 1
        expect(session).to include(:flash)
      end
      it { expect(response.cookies).not_to be_present }
      it { expect(response).to redirect_to(login_path) }
      it { expect(flash[:notice]).to eql(I18n.t(:logout_successfull, scope: [:flash, :notice])) }
    end

    context 'when no user logged in' do
      before { delete :destroy }
      it { expect(response).to redirect_to(login_path) }
      it { expect(flash[:alert]).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) } 
    end
  end

end
