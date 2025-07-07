Rails.application.routes.draw do
  devise_for :users
  get "up", to: "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    # Health checkエンドポイント
    get "health", to: "health#index"

    # 認証用エンドポイント
    post "login", to: "sessions#create"
    post "logout", to: "sessions#destroy"
    get "me", to: "sessions#show"
  end

  # ルートパスの設定
  root "application#index"
end
