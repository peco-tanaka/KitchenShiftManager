Rails.application.routes.draw do
  namespace :api do
    resources :issues do
      resources :reviews, except: [:show, :update]
    end
    
    get '/health', to: 'application#health'
  end
  
  # Serve static files from React app
  get '*path', to: 'application#fallback_index_html', constraints: ->(request) do
    !request.xhr? && request.format.html?
  end
end