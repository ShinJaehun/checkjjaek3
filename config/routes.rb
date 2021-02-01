Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  root 'posts#index'

  resources :posts do
    post 'like', to: 'posts#like', as: :like, on: :member
    resources :comments, only: [:create, :edit, :update, :destroy] do
      member do
        get :reply
      end
    end
  end

  resources :books do
    resources :posts, module: :books
  end

  resources :messages do
    resources :posts, module: :messages
  end

  resources :photos do
    resources :posts, module: :photos
  end

  resources :users, only:[:show] do
    post 'follow', to: 'users#follow', as: :follow, on: :member
  end

  get '/book_search', to: 'books#book_search'

  get '/posts/hashtag/:name', to: 'posts#hashtags'

  get 'search', to: 'posts#search'

end
