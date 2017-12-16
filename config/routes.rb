Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#index'
  # controller :registrations do
  #   get 'signup', to: 'new'
  #   post 'signup', to: 'create'
  # end

  resources :registrations, only: [:new, :create]
  # resources :sessions, only: [:new, :create]
  # controller :sessions do
  #   get 'login' => :new
  #   post 'login' => :create
  # end

  # controller :sessions do
  #   get 'login', to: :new
  #   post 'login', to: :create
  # end

  # get 'login', to: :new, controller: 'sessions'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  # resources :sessions, path_names: { new: 'login', create: 'login' }, only: [:new, :create]
end
