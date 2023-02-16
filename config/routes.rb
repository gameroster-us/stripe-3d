Rails.application.routes.draw do
  root "home#index"
  get 'home/index'
  devise_for :users, controllers: { sessions: 'users/sessions' }
  resources :charges
  get 'success', to: 'charges#success'
  get 'fail', to: 'charges#fail'
  get 'payment_data', to: 'charges#payment_data'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
end
