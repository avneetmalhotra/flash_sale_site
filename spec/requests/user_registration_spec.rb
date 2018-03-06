require "rails_helper"

RSpec.describe "User Registration", type: :request do
  context 'not logged in' do
    it 'creates new user and redirects to login page' do
      get '/registrations/new'
      expect(response).to render_template('registrations/new')

      post '/registrations', params: { user: { name: 'user_name',email: 'user_email@mail.com', password: 'password', password_confirmation: 'password' } }
      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq(I18n.t(:confirmation_email_sent, scope: [:flash, :notice]))
    end
  
    it 'does not create user for invalid user information' do
      get '/registrations/new'
      expect(response).to render_template('registrations/new')

      post '/registrations', params: { user: { name: 'user_name',email: 'user_email@mail.com', password: 'password', password_confirmation: 'wrong_password' } }
      expect(response).to render_template('registrations/new')
      expect(assigns(:user).errors).not_to be_empty
    end
  end

  context 'when logged in' do
    let!(:user) { FactoryBot.create(:user, :confirmed) }
    before(:example) do
      post '/login', params: { user: { email: user.email, password: 'password' } }
      expect(flash[:notice]).to eq(I18n.t(:login_successfull, scope: [:flash, :notice]))
    end

    it 'denies access to registrations#new' do
      get '/registrations/new'
      expect(response).not_to render_template('registrations/new')
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(I18n.t(:logout_to_continue, scope: [:flash, :alert]))
    end

    it 'denies access to registrations#create' do
      post '/registrations', params: { user: { name: 'user_name',email: 'user_email@mail.com', password: 'password', password_confirmation: 'password' } }
      expect(response).not_to redirect_to(login_path)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(I18n.t(:logout_to_continue, scope: [:flash, :alert]))
    end
  end

end
