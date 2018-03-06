require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  it { expect(controller.class.ancestors).to include(ApplicationController) }
  
  it { is_expected.to use_before_action(:set_user) }
  it { is_expected.to use_before_action(:ensure_not_admin) }

  describe 'GET #index' do
    context 'when user is logged in' do
      context 'when user is admin' do
        let!(:user) { FactoryBot.create(:user, :admin) }
        before { request.session[:user_id] = user.id }
        context 'shows all users' do
          before { get :index }
          it { expect(assigns(:users)).to include(user) }
          it { expect(assigns(:users).count).to eql 1 }
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

    context 'when no user is logged in' do
      before { get :index }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

  describe 'GET #new' do
    context 'when user is logged in' do
      context 'when user is admin' do
        let!(:user) { FactoryBot.create(:user, :admin) }
        before { request.session[:user_id] = user.id }
        before { get :new }
        it { expect(assigns(:user)).to be_a_new(User) }
        it { expect(response).to render_template(:new) }
      end

      context 'when user is not admin' do
        let!(:user) { FactoryBot.create(:user) }
        before do
          request.session[:user_id] = user.id
          get :new
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end
    end

    context 'when no user is logged in' do
      before { get :new }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

  describe 'POST #create' do
    context 'when user is logged in' do
      context 'when user is admin' do
        let!(:user) { FactoryBot.create(:user, :admin) }
        before { request.session[:user_id] = user.id }
        context 'fails for invalid user' do
          before { post :create, params: { user: { name: 'user_name', email: 'random', password: 'password', password_confirmation: 'wrong_password', active: '1' } } }
          it { expect(response).to render_template(:new) }
        end

        context 'successfully created' do
          before { post :create, params: { user: { name: 'user_name', email: 'random@mail.com', password: 'password', password_confirmation: 'password', active: '1' } } }
          it { expect(response).to redirect_to(admin_users_path) }
          it { expect(request.flash.notice).to eql(I18n.t(:confirmation_email_sent, scope: [:flash, :notice])) }
        end
      end

      context 'when user is not admin' do
        let!(:user) { FactoryBot.create(:user) }
        before do
          request.session[:user_id] = user.id
          post :create
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end
    end

    context 'when no user is logged in' do
      before { post :create }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

  describe 'GET #show' do
    context 'when user is logged in' do
      let!(:user) { FactoryBot.create(:user, :admin) }
      context 'when user is admin' do
        before { request.session[:user_id] = user.id }
        context 'failure' do
          before { get :show, params: { id: 'sdf' } }
          context 'for invalid user'do
            it { expect(response.status).to eq(404) }
            it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
          end
        end

        context 'successfull' do
          before { get :show, params: { id: user.id } }
          it { expect(response).to render_template(:show) }
        end
      end

      context 'when user is not admin' do
        let!(:user) { FactoryBot.create(:user) }
        before do
          request.session[:user_id] = user.id
          get :show, params: { id: 3 }
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end
    end

    context 'when no user is logged in' do
      before { get :show, params: { id: 3 } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

  describe 'GET #edit' do
    context 'when user is logged in' do
      let!(:user) { FactoryBot.create(:user, :admin) }
      context 'when user is admin' do
        before { request.session[:user_id] = user.id }
        context 'failure' do
          context 'for invalid user'do
            before { get :edit, params: { id: 'sdf' } }
            it { expect(response.status).to eq(404) }
            it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
          end

          context 'when user to edit is admin' do
            let!(:user2) { FactoryBot.create(:user, :admin, email: 'new_email@mail.com') }
            before { get :edit, params: { id: user2.id } }
            it { expect(response).to redirect_to(admin_users_path) }
            it { expect(request.flash.alert).to eql(I18n.t(:not_authorized, scope: [:flash, :alert])) }
          end
        end

        context 'successfull' do
          let!(:user2) { FactoryBot.create(:user, email: 'new_email@mail.com') }
          before { get :edit, params: { id: user2.id } }
          it { expect(response).to render_template(:edit) }
        end
      end

      context 'when user is not admin' do
        let!(:user) { FactoryBot.create(:user) }
        before do
          request.session[:user_id] = user.id
          get :edit, params: { id: 3 }
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end
    end

    context 'when no user is logged in' do
      before { get :edit, params: { id: 3 } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

  describe 'PATCH #update' do
    context 'when user is logged in' do
      let!(:user) { FactoryBot.create(:user, :admin) }
      context 'when user is admin' do
        before { request.session[:user_id] = user.id }
        context 'failure' do
          context 'for invalid user'do
            before { patch :update, params: { id: 'sdf' } }
            it { expect(response.status).to eq(404) }
            it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
          end

          context 'when user to update is admin' do
            let!(:user2) { FactoryBot.create(:user, :admin, email: 'new_email@mail.com') }
            before { patch :update, params: { id: user2.id } }
            it { expect(response).to redirect_to(admin_users_path) }
            it { expect(request.flash.alert).to eql(I18n.t(:not_authorized, scope: [:flash, :alert])) }
          end

          context 'when update fails due to invalid attribute' do
            let!(:user2) { FactoryBot.create(:user, email: 'new_email@mail.com') }
            before { patch :update, params: { id: user2.id, user: { name: 'new_USER_name', active: false, password: 'new_pass', password_confirmation: 'wron_pass' } } }
            it { expect(response).to render_template(:edit) }
          end
        end

        context 'successfull' do
          let!(:user2) { FactoryBot.create(:user, email: 'new_email@mail.com') }
          before { patch :update, params: { id: user2.id, user: { name: 'new_USER_name', active: false, password: 'new_pass', password_confirmation: 'new_pass' } } }
          it { expect(response).to redirect_to(admin_users_path) }
          it { expect(request.flash.notice).to eql(I18n.t(:customer_account_updated, scope: [:flash, :notice])) }
        end
      end

      context 'when user is not admin' do
        let!(:user) { FactoryBot.create(:user) }
        before do
          request.session[:user_id] = user.id
          patch :update, params: { id: 3 }
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end
    end

    context 'when no user is logged in' do
      before { patch :update, params: { id: 3 } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

end
