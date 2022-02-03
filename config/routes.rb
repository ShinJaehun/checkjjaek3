Rails.application.routes.draw do
  resources :groups
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

  get 'join_group/:id', to: 'groups#join_group', as: :join_group
  get 'apply_group/:id', to: 'groups#apply_group', as: :apply_group
  get 'approve_user/:id', to: 'groups#approve_user', as: :approve_user
  get 'resume_user/:id', to: 'groups#resume_user', as: :resume_user
  get 'suspend_user/:id', to: 'groups#suspend_user', as: :suspend_user
  delete 'leave_group/:id', to: 'groups#leave_group', as: :leave_group
  delete 'cancel_apply_group/:id', to: 'groups#cancel_apply_group', as: :cancel_apply_group

  get 'approve_group/:id', to: 'groups#approve_group', as: :approve_group

  get 'group_manager/:id', to: 'groups#group_manager', as: :group_manager
  get 'admin', to: 'users#admin', as: :admin

end
