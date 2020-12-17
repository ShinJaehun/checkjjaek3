Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  root 'posts#index'

  resources :posts do
    post 'like', to: 'posts#like', as: :like, on: :member
  end

  resources :users, only:[:show] do
    post 'follow', to: 'users#follow', as: :follow, on: :member
  end

  get '/book_search', to: 'books#book_search'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
