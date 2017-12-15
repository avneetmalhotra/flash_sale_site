Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#index'
  # controller :registrations do
  #   get 'signup', to: 'new'
  #   post 'signup', to: 'create'
  # end

  resources :registrations, only: [:new, :create]
end
