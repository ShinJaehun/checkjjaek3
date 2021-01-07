Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  root 'posts#index'

  resources :posts do
    post 'like', to: 'posts#like', as: :like, on: :member
    resources :comments, only: [:create, :destroy]
    #post 'comments', to: 'comments#create'
  end

  resources :books do
    resources :posts, module: :books
  end

  resources :users, only:[:show] do
    post 'follow', to: 'users#follow', as: :follow, on: :member
  end

  get '/book_search', to: 'books#book_search'

  get '/posts/hashtag/:name', to: 'posts#hashtags'

  get 'search', to: 'posts#search'

end
