Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    get "health", to: "health#index"
  end

  # ルートパスの設定
  root "application#index"
end
