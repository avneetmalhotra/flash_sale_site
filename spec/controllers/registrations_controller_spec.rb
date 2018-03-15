require "rails_helper"

RSpec.describe RegistrationsController, type: :controller do

  it { expect(RegistrationsController.ancestors).to include(ApplicationController) }

  it { is_expected.to use_before_action(:ensure_logged_out) }
  it { is_expected.to use_before_action(:set_user) }
  # it { is_expected.not_to use_before_action(:authenticate_user) }

  describe 'GET #new' do
    context 'when user logged in' do
      let!(:user) { FactoryBot.create(:user) }
      before do
        # allow(controller).to receive(:current_user).and_return(true)
        request.session[:user_id] = user.id
        get :new
      end
      it { expect(response).to redirect_to(root_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:logout_to_continue, scope: [:flash, :alert])) }
    end

    context 'when user logged out' do
      it 'initialize new user' do
        get :new
        expect(assigns(:user)).to be_a_new(User)
      end
    end
  end

  describe 'POST #create' do
    context 'when user logged in' do
      let!(:user) { FactoryBot.create(:user) }
      before do
        # allow(controller).to receive(:current_user).and_return(true)
        request.session[:user_id] = user.id
        post :create
      end
      it { expect(response).to redirect_to(root_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:logout_to_continue, scope: [:flash, :alert])) }
    end

    context 'when user logged out' do
      let!(:user) { FactoryBot.create(:user) }
      context 'user creation fails' do
        before do
          post :create, params: { user: { name: 'user_name',email: 'user_email@mail.com', password: 'password', password_confirmation: 'wrong_password' } }
        end
        it do
          strong_params = controller.send(:new_user_params)
          expect(strong_params.permitted?).to be true
          expect(strong_params).to include(:name, :email, :password, :password_confirmation)
        end
        it { expect(response).to render_template(:new) }
      end
      context 'user successfully created' do
        before do
          params = { user: { name: 'user_name', email: 'use_test@mail.com', password: 'password', password_confirmation: 'password' } }
          post :create, params: params
        end
        it { expect(response).to redirect_to(login_path) }
        it { expect(request.flash.notice).to eql(I18n.t(:confirmation_email_sent, scope: [:flash, :notice])) }
      end
    end
  end

  describe 'GET #edit' do
    context 'when user logged in' do
      let!(:user) { FactoryBot.create(:user) }
      before do
        request.session[:user_id] = user.id
      end
      it 'set user' do
        get :edit, params: { id: user.id }
        expect(assigns(:user)).to eql(user)
        expect(response).to render_template(:edit)
      end
      it 'edit other user than logged in' do
        get :edit, params: { id: 0 }
        expect(response.status).to eq(404)
        expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s)
      end
    end

    context 'when user logged out' do
      before { post :edit, params: { id: 2 } }
      it { expect(response).to redirect_to(login_path) }      
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

  describe 'PATCH #update' do
    context 'when user logged in' do
      let!(:user) { FactoryBot.create(:user) }
      before do
        request.session[:user_id] = user.id
      end

      it 'update fails' do
        patch :update, params: { id: user.id, user: { name: 'user_name', password: 'password', password_confirmation: 'wrong_password' } }
        expect(response).to render_template(:edit)
      end

      it 'update fails when try to update another user' do
        patch :update, params: { id: user.id + 3, user: { name: 'user_name', password: 'password', password_confirmation: 'wrong_password' } }
        expect(response.status).to eq(404)
        expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s)
      end
     
      context 'update successfull' do
        before do
          params = { id: user.id, user: { name: 'new_name', password: 'new_password', password_confirmation: 'new_password', current_password: user.password } }
          patch :update, params: params
        end
        it do
          strong_params = controller.send(:update_user_params)
          expect(strong_params.permitted?).to be true
          expect(strong_params).to include(:name, :password, :password_confirmation, :current_password)
        end
        it { expect(response).to redirect_to(root_url) }
        it { expect(request.flash.notice).to eql(I18n.t(:account_updated, scope: [:flash, :notice])) }
      end
    end

    context 'when user logged out' do
      before { post :update, params: { id: 2 } }
      it { expect(response).to redirect_to(login_path) }      
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

end
