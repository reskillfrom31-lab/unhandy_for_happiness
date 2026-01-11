Rails.application.routes.draw do
  get 'setup/index'
  devise_for :users
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "welcome#index"
  
  resources :checklists do
    post 'create_answer', on: :member
    get 'check_all_answered', on: :collection
    get 'public_index', on: :collection
    get 'manage', on: :collection  # ← 追加：質問管理画面
  end
end