# CORS設定を追加して、フロントエンドからのAPIリクエストを許可する
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # 開発環境用設定
    origins Rails.env.development? ? ["http://localhost:5173", "http://127.0.0.1:5173"] : ENV.fetch("FRONTEND_ORIGIN", "")

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true  # Session Cookie認証のため必要
  end
end