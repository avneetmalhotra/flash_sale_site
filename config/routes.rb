Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#index'
  
  resources :registrations, only: [:new, :create, :edit, :update]

  resources :confirmations, only: [:new, :create]
  get 'user/confirm', to: 'confirmations#confirm'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  resources :passwords, only: [:new, :create]
  get 'password/reset', to: 'passwords#edit'
  patch 'password/reset', to: 'passwords#update'

  get 'admin', to: redirect('admin/deals')

  namespace :admin do
    resources :deals
    resources :users, except: [:destroy]
    resources :orders, only: [:index, :show], param: :invoice_number do
      member do
        patch 'cancel'
        patch 'deliver'
      end
    end

    namespace :report do
      resources :deals_report, only: [:index]
      resources :customers_report, only: [:index]
      resources :revenue_report, only: [:index]
    end
  end

  resources :deals, only: [:index, :show] do
    member do
      get 'polling'
    end
  end

  resources :line_items, only: [:create, :destroy, :update]

  resources :orders, only: [:index, :destroy, :show], param: :invoice_number do
    patch 'cancel', on: :member
  end
  get 'cart', to: 'orders#cart'

  resources :addresses, only: [:new, :create]
  patch 'address/associate_address', to: "addresses#associate_address"

  resources :payments, only: [:new, :create]

  namespace :api do
    namespace :v1 do
      resources :deals, only: [] do
        collection do
          get 'live'
          get 'expired'
        end
      end

      resources :orders, path: :myorders, only: [:index]
    end
  end
end
