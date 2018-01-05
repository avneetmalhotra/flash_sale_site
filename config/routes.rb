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
  end

  resources :deals, only: [:show]

end
