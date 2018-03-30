require "rails_helper"

RSpec.describe 'Order flow', type: :request do
  describe 'when no user is logged in' do
    let!(:live_deal) { FactoryBot.create(:deal) }
    before { live_deal.update_columns(publishing_date: Date.current, start_at: Time.current, end_at: 1.day.after) }
    
    it 'cannot order the deal' do
      post '/line_items', params: { deal_id: live_deal.id, line_item: { quantity: 1 } }
      expect(response).to redirect_to(login_path)
      expect(flash[:alert]).to eql(I18n.t(:login_to_continue, scope: [:flash, :alert]))
    end
  end

  describe 'when user is logged in' do
    let!(:live_deal) { FactoryBot.create(:deal, :with_images) }
    let!(:user) { FactoryBot.create(:user, :confirmed) }
    before(:example) do
      post '/login', params: { user: { email: user.email, password: 'password' } }
      expect(flash[:notice]).to eq(I18n.t(:login_successfull, scope: [:flash, :notice]))
    end

    it 'placing order successfully' do
      post '/line_items', params: { deal_id: live_deal.id, line_item: { quantity: 1 } }
      expect(response).to redirect_to(cart_path)
      expect(flash[:notice]).to eql(I18n.t(:deal_added_to_cart, scope: [:flash, :notice], deal_title: live_deal.title))

      get '/addresses/new'
      expect(response).to render_template('addresses/new')

      post '/addresses', params: { address: { house_number: 'hno1' , street: 'long street', city: 'some city' , state: 'some state',  country: 'some country', pincode: 1111 } }
      expect(response).to redirect_to(new_payment_path)
      expect(flash[:notice]).to eql(I18n.t(:address_successfully_added, scope: [:flash, :notice]))
    
      get '/payments/new'
      expect(response).to render_template('payments/new')
    end

    context 'failures' do
      it 'invalid deal cannot be added to cart' do
        post '/line_items', params: { deal_id: 'invalid_id', line_item: { quantity: 1 } }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eql(I18n.t(:deal_cannot_be_added_to_cart, scope: [:flash, :alert]))
      end

      it 'deal cannot be added due to invalid line_item' do
        post '/line_items', params: { deal_id: live_deal.id, line_item: { quantity: 2 } }
        expect(response).to redirect_to(deal_path(live_deal))
        expect(flash[:alert]).to eql(assigns(:line_item).pretty_errors)
      end

      it 'address cannot be added because current order absent' do
        post '/line_items', params: { deal_id: live_deal.id, line_item: { quantity: 1 } }
        expect(response).to redirect_to(cart_path)
        expect(flash[:notice]).to eql(I18n.t(:deal_added_to_cart, scope: [:flash, :notice], deal_title: live_deal.title))

        allow_any_instance_of(AddressesController).to receive(:current_order).and_return(nil)
        get '/addresses/new'
        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to eql(I18n.t(:cart_empty, scope: [:flash, :alert]))
      end

      it 'address cannot be added because checkout is not allowed' do
        post '/line_items', params: { deal_id: live_deal.id, line_item: { quantity: 1 } }
        expect(response).to redirect_to(cart_path)
        expect(flash[:notice]).to eql(I18n.t(:deal_added_to_cart, scope: [:flash, :notice], deal_title: live_deal.title))

        allow_any_instance_of(Order).to receive(:checkout_allowed?).and_return(false)
        get '/addresses/new'
        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to eql(controller.send(:current_order).pretty_errors)
      end

      it 'address cannot be added because current_order state cannot be updated' do
        post '/line_items', params: { deal_id: live_deal.id, line_item: { quantity: 1 } }
        expect(response).to redirect_to(cart_path)
        expect(flash[:notice]).to eql(I18n.t(:deal_added_to_cart, scope: [:flash, :notice], deal_title: live_deal.title))

        allow_any_instance_of(Order).to receive(:can_add_address?).and_return(true)
        allow_any_instance_of(Order).to receive(:add_address).and_return(false)
        get '/addresses/new'
        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to eql(controller.send(:current_order).pretty_errors)
      end

      it 'payment cannot be done when order is absent' do
        post '/line_items', params: { deal_id: live_deal.id, line_item: { quantity: 1 } }
        expect(response).to redirect_to(cart_path)
        expect(flash[:notice]).to eql(I18n.t(:deal_added_to_cart, scope: [:flash, :notice], deal_title: live_deal.title))

        get '/addresses/new'
        post '/addresses', params: { address: { 
                                      house_number: 'hno', 
                                      street: 'street',
                                      city: 'city',
                                      state: 'state',
                                      country: 'country',
                                      pincode: 111 
                                      } 
                                    }
        expect(response).to redirect_to(new_payment_path)
        expect(flash[:notice]).to eql(I18n.t(:address_successfully_added, scope: [:flash, :notice]))

        allow_any_instance_of(PaymentsController).to receive(:current_order).and_return(nil)
        get '/payments/new'
        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to eql(I18n.t(:cart_empty, scope: [:flash, :alert]))
      end

      it 'payment cannot be done if checkout is not allowed' do
        post '/line_items', params: { deal_id: live_deal.id, line_item: { quantity: 1 } }
        expect(response).to redirect_to(cart_path)
        expect(flash[:notice]).to eql(I18n.t(:deal_added_to_cart, scope: [:flash, :notice], deal_title: live_deal.title))

        get '/addresses/new'
        post '/addresses', params: { address: { 
                                      house_number: 'hno', 
                                      street: 'street',
                                      city: 'city',
                                      state: 'state',
                                      country: 'country',
                                      pincode: 111 
                                      } 
                                    }
        expect(response).to redirect_to(new_payment_path)
        expect(flash[:notice]).to eql(I18n.t(:address_successfully_added, scope: [:flash, :notice]))

        allow_any_instance_of(Order).to receive(:checkout_allowed?).and_return(false)
        get '/payments/new'
        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to eql(controller.send(:current_order).pretty_errors)
      end

      it 'payment cannot be done if current_order state is cart' do
        post '/line_items', params: { deal_id: live_deal.id, line_item: { quantity: 1 } }
        expect(response).to redirect_to(cart_path)
        expect(flash[:notice]).to eql(I18n.t(:deal_added_to_cart, scope: [:flash, :notice], deal_title: live_deal.title))

        get '/addresses/new'
        post '/addresses', params: { address: { 
                                      house_number: 'hno', 
                                      street: 'street',
                                      city: 'city',
                                      state: 'state',
                                      country: 'country',
                                      pincode: 111 
                                      } 
                                    }
        expect(response).to redirect_to(new_payment_path)
        expect(flash[:notice]).to eql(I18n.t(:address_successfully_added, scope: [:flash, :notice]))

        allow_any_instance_of(Order).to receive(:cart?).and_return(true)
        get '/payments/new'
        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to eql(I18n.t(:address_not_added, scope: [:flash, :alert]))
      end

      it 'payment cannot be done if current_order state is cart' do
        post '/line_items', params: { deal_id: live_deal.id, line_item: { quantity: 1 } }
        expect(response).to redirect_to(cart_path)
        expect(flash[:notice]).to eql(I18n.t(:deal_added_to_cart, scope: [:flash, :notice], deal_title: live_deal.title))

        get '/addresses/new'
        post '/addresses', params: { address: { 
                                      house_number: 'hno', 
                                      street: 'street',
                                      city: 'city',
                                      state: 'state',
                                      country: 'country',
                                      pincode: 111 
                                      } 
                                    }
        expect(response).to redirect_to(new_payment_path)
        expect(flash[:notice]).to eql(I18n.t(:address_successfully_added, scope: [:flash, :notice]))

        allow_any_instance_of(Order).to receive(:can_pay?).and_return(true)
        allow_any_instance_of(Order).to receive(:pay).and_return(false)
        get '/payments/new'
        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to eql(controller.send(:current_order).pretty_errors)
      end

      it 'payment cannot be done due to an exception while creating payment' do
        post '/line_items', params: { deal_id: live_deal.id, line_item: { quantity: 1 } }
        expect(response).to redirect_to(cart_path)
        expect(flash[:notice]).to eql(I18n.t(:deal_added_to_cart, scope: [:flash, :notice], deal_title: live_deal.title))

        get '/addresses/new'
        post '/addresses', params: { address: { 
                                      house_number: 'hno', 
                                      street: 'street',
                                      city: 'city',
                                      state: 'state',
                                      country: 'country',
                                      pincode: 111 
                                      } 
                                    }
        expect(response).to redirect_to(new_payment_path)
        expect(flash[:notice]).to eql(I18n.t(:address_successfully_added, scope: [:flash, :notice]))

        get '/payments/new'

        allow_any_instance_of(Payment).to receive(:create_stripe_record!).and_raise('abc')
        post '/payments'
        expect(response).to redirect_to(new_payment_path)
        expect(flash[:alert]).to eql('abc')
      end

    end
  end
end
