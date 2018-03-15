require "rails_helper"

RSpec.describe Admin::DealsController, type: :controller do
  
  it { expect(Admin::DealsController.ancestors).to include(Admin::BaseController) }
  it { is_expected.to use_before_action(:set_deal) }
  
  describe 'GET #index' do
    context 'when logged in' do
      context 'when user is admin' do
        let!(:user) { FactoryBot.create(:user, :admin) }
        before do
          request.session[:user_id] = user.id
        end

        it 'live deals' do
          live_deal = FactoryBot.create(:deal)
          live_deal.update_columns(publishing_date: Date.current, start_at: Time.current, end_at: 1.day.after)
          get :index
          expect(assigns(:live_deals)).to include(live_deal)
        end

        it 'expired deals' do
          expired_deal = FactoryBot.create(:deal)
          expired_deal.update_columns(publishing_date: 2.day.before, start_at: 2.day.before, end_at: 1.day.before)
          get :index
          expect(assigns(:expired_deals)).to include(expired_deal)
        end

        it 'future deals' do
          future_deal = FactoryBot.create(:deal)
          future_deal.update_columns(publishing_date: 2.days.after, start_at: nil)
          get :index
          expect(assigns(:future_deals)).to include(future_deal)
        end

        it 'unpublished deals' do
          unpublished_deal = FactoryBot.create(:deal)
          unpublished_deal.update_columns(publishing_date: nil, start_at: nil, end_at: nil)
          get :index
          expect(assigns(:unpublished_deals)).to include(unpublished_deal)
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

    context 'when logged out' do
      before { get :index }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

  describe 'GET #new' do
    context 'when logged in' do
      context 'when user is admin' do
        let!(:user) { FactoryBot.create(:user, :admin) }
        before do
          request.session[:user_id] = user.id
        end
        it 'initializes new deal' do
          get :new
          expect(assigns(:deal)).to be_a_new(Deal)
        end
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

    context 'when logged out' do
      before { get :new }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

  describe 'POST #create' do
    context 'when logged in' do
      context 'when user is admin' do
        let!(:user) { FactoryBot.create(:user, :admin) }
        before do
          request.session[:user_id] = user.id
        end

        context 'deal successfully created' do
          before do
            post :create, params: { deal: { 
                                    title: 'title1',
                                    description: 'description afa',
                                    price: 123,
                                    discount_price: 34,
                                    quantity: 11
                                  } 
                                }
          end
          it do
            strong_params = controller.send(:new_deal_params)
            expect(strong_params.permitted?).to be true
            # expect(strong_params).to include(:title, :description, :price, :discount_price, :quantity, :publishing_date, images_attributes: [:avatar, :_destroy])
          end
          it { expect(assigns(:deal).persisted?).to be true }
          it { expect(response).to redirect_to(admin_deals_path) }
          it { expect(request.flash.notice).to eql(I18n.t(:deal_created, scope: [:flash, :notice])) }
        end

        context 'deal creation fails' do
          before do
            post :create, params: { deal: { 
                                    title: '',
                                    description: 'description afa',
                                    price: 123,
                                    discount_price: 34,
                                    quantity: 11
                                  } 
                                }
          end
          it { expect(response).to render_template(:new) }
        end

      end

      context 'when user is not admin' do
        let!(:user) { FactoryBot.create(:user) }
        before do
          request.session[:user_id] = user.id
          post :create, params: { deal: { 
                                  title: 'title1',
                                  description: 'description afa',
                                  price: 123,
                                  discount_price: 34,
                                  quantity: 11
                                } 
                              }
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end
    end

    context 'when logged out' do
      before { post :create }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

  describe 'GET #edit' do
    let!(:deal) { FactoryBot.create(:deal) }
    context 'when logged in' do
      context 'when user is admin' do
        let!(:user) { FactoryBot.create(:user, :admin) }
        before do
          request.session[:user_id] = user.id
        end
      end

      context 'when user is not admin' do
        let!(:user) { FactoryBot.create(:user) }
        before do
          request.session[:user_id] = user.id
          get :edit, params: { id: deal.id }
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end
    end

    context 'when logged out' do
      before { get :edit, params: { id: deal.id } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

  describe 'PATCH #update' do
    let!(:deal) { FactoryBot.create(:deal) }
    context 'when logged in' do
      context 'when user is admin' do
        let!(:user) { FactoryBot.create(:user, :admin) }
        let!(:deal) { FactoryBot.create(:deal) }
        before do
          request.session[:user_id] = user.id
        end
        context 'deal updated successfully' do
          before do
            patch :update, params: {id: deal.id, deal: { 
                                                  title: 'new_title',
                                                  description: 'description afa',
                                                  price: 123,
                                                  discount_price: 34,
                                                  quantity: 11
                                                } 
                                   }
          end
          it do
            strong_params = controller.send(:update_deal_params)
            expect(strong_params.permitted?).to be true
            # expect(strong_params).to include(:title, :description, :price, :discount_price, :quantity, :publishing_date, images_attributes: [:avatar, :_destroy])
          end
          it { expect(response).to redirect_to(admin_deals_path) }
          it { expect(request.flash.notice).to eql(I18n.t(:deal_updated, scope: [:flash, :notice])) }
        end

        context 'deal updation fails' do
          before do
            patch :update, params: {id: deal.id, deal: { 
                                                  title: '',
                                                  description: 'description afa',
                                                  price: 123,
                                                  discount_price: 34,
                                                  quantity: 11
                                                } 
                                  }
          end
          it { expect(response).to render_template(:edit) }
        end

      end

      context 'when user is not admin' do
        let!(:user) { FactoryBot.create(:user) }
        before do
          request.session[:user_id] = user.id
          patch :update, params: { id: deal.id }
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end
    end

    context 'when logged out' do
      before { patch :update, params: { id: deal.id } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

  describe 'GET #show' do
    let!(:deal) { FactoryBot.create(:deal) }
    context 'when logged in' do
      context 'when user is admin' do
        let!(:user) { FactoryBot.create(:user, :admin) }
        let!(:deal) { FactoryBot.create(:deal) }
        before do
          request.session[:user_id] = user.id
        end
        context 'show valid deal' do
          before { get :show, params: { id: deal.id } }
          it { expect(response).to render_template(:show) } 
        end
        context 'does not show invalid deal' do
          before { get :show, params: { id: 0 } }
          it { expect(response.status).to eq(404) }
          it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
        end
  
      end

      context 'when user is not admin' do
        let!(:user) { FactoryBot.create(:user) }
        before do
          request.session[:user_id] = user.id
          get :show, params: { id: deal.id }
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end
    end

    context 'when logged out' do
      before { get :show, params: { id: deal.id } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

  describe 'DELETE #destroy' do
    let!(:deal) { FactoryBot.create(:deal) }
    context 'when logged in' do
      context 'when user is admin' do
        let!(:user) { FactoryBot.create(:user, :admin) }
        before do
          request.session[:user_id] = user.id
        end
        context 'deal destroyed successfully' do
          before { delete :destroy, params: { id: deal.id } }
          it { expect(response).to redirect_to(admin_deals_path) }
          it { expect(request.flash.notice).to eql(I18n.t(:deal_successfully_destroyed, scope: [:flash, :notice])) }
        end

        context 'deal destruction fails' do
          before { deal.update_columns(publishing_date: 2.days.before, start_at: 2.days.before, end_at: 1.day.before) }
          before { delete :destroy, params: { id: deal.id } }
          it { expect(response).to redirect_to(admin_deals_path) }
          it { expect(request.flash.alert).to eql(assigns(:deal).pretty_errors) }
        end
      end

      context 'when user is not admin' do
        let!(:user) { FactoryBot.create(:user) }
        before do
          request.session[:user_id] = user.id
          delete :destroy, params: { id: deal.id }
        end
        it { expect(response.status).to eq(404) }
        it { expect(response).to render_template(file: Rails.root.join('public', '404.html').to_s) }
      end
    end

    context 'when logged out' do
      before { delete :destroy, params: { id: deal.id } }
      it { expect(response).to redirect_to(login_path) }
      it { expect(request.flash.alert).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert])) }
    end
  end

end
