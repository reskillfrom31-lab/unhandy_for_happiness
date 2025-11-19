Rails.application.routes.draw do
  get 'setup/index'
  devise_for :users
  get 'checklists/index'
  get 'checklists/new'
  get 'checklists/create'
  get 'checklists/edit'
  get 'checklists/update'
  get 'checklists/destroy'
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "checklists#index"
  resources :checklists do
    post 'create_answer', on: :member
    get 'check_all_answered', on: :collection
  end
end