Rails.application.routes.draw do

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  root 'movies#index'

  resources :movies do
    get 'vote', to: 'movies#vote'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
