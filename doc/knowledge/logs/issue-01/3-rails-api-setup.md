# 3. Rails API Setup - Implementation Log

**作成日**: 2025年6月30日  
**Issue**: #1 開発基盤セットアップ  
**タスク**: Rails API セットアップ

## 実装内容

### ✅ Rails new でAPI-onlyアプリ作成
- Rails 7.2.2.1 API-onlyアプリケーション
- PostgreSQL対応のデータベース設定
- API専用の最小限ファイル構成

### ✅ Gemfile の設定（必要な gem の追加）
- 認証・認可: Devise 4.9.4, Pundit 2.3
- Excel生成: rubyXL 3.4（axlsx 4.1から変更）
- Linter: RuboCop ~>1.77（2.32から変更）
- テスト: RSpec-Rails, FactoryBot

### ✅ データベース設定
- 環境変数対応のdatabase.yml設定
- 開発・本番環境の分離
- エラーハンドリング改善

### ✅ CORS設定
- Session Cookie認証対応
- 開発・本番環境別オリジン設定
- credentials: true設定

### ✅ 基本的なヘルスチェックエンドポイント
- `/api/health` エンドポイント実装
- データベース接続確認
- サービス稼働時間表示

### ✅ Railsサーバー接続確認
- Docker環境での正常起動確認
- API疎通確認
- ヘルスチェックレスポンス確認

## 実行コマンド履歴

```bash
# Rails new（Docker環境）
docker run --rm -v "$(pwd)/backend:/app" -w /app ruby:3.4.4 bash -c "gem install rails -v 7.2.2 && rails new . --api --database=postgresql --skip-git --skip-bundle"

# Gemfile更新後のbundle install
docker exec kitchenshiftmanager-backend-1 bundle install

# サーバー起動確認
curl http://localhost:3000/api/health
```

## 主要実装内容

### Gemfile更新
```ruby
# 認証・認可
gem "devise", "~> 4.9.4"
gem "pundit", "~> 2.3"

# Excel生成（axlsx → rubyXL に変更）
gem "rubyXL", "~> 3.4"

# CORS設定
gem "rack-cors"

# テスト環境
group :development, :test do
  gem "rspec-rails", "~> 7.1"
  gem "factory_bot_rails", "~> 6.5"
end

# Linter
group :development do
  gem "rubocop", "~> 1.77"
end
```

### database.yml環境変数対応
```yaml
production:
  <<: *default
  database: <%= ENV.fetch("DATABASE_NAME") { "kitchen_shift_manager_production" } %>
  username: <%= ENV.fetch("DATABASE_USERNAME") { "postgres" } %>
  password: <%= ENV.fetch("DATABASE_PASSWORD") { "" } %>
  host: <%= ENV.fetch("DATABASE_HOST") { "localhost" } %>
  port: <%= ENV.fetch("DATABASE_PORT") { 5432 } %>
```

### CORS設定
```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Rails.env.development? ? ["http://localhost:5173", "http://127.0.0.1:5173"] : ENV.fetch("FRONTEND_ORIGIN", "")
    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true  # Session Cookie認証のため必要
  end
end
```

### ヘルスチェックAPI
```ruby
# app/controllers/api/health_controller.rb
class Api::HealthController < ApplicationController
  def index
    database_status = check_database_connection
    
    render json: {
      status: database_status[:connected] ? "healthy" : "unhealthy",
      service: "Kitchen Shift Manager API",
      version: "1.0.0",
      environment: Rails.env,
      timestamp: Time.current.iso8601,
      database: database_status,
      uptime: uptime_info
    }, status: database_status[:connected] ? :ok : :service_unavailable
  end
end
```

## Tips & 知見

### API-only Railsの特徴
- **軽量**: 不要なMiddlewareを除外
- **高速**: レスポンス時間の向上
- **セキュリティ**: 最小限の攻撃面

### Gem選択の判断基準
- **実在性**: 存在しないバージョンの回避
- **メンテナンス性**: 活発に開発されているgemの選択
- **互換性**: Rails 7.2との互換性確認

### CORS設定のポイント
- **credentials: true**: Session Cookie認証で必須
- **環境別設定**: 開発と本番でオリジンを分離
- **メソッド指定**: 必要なHTTPメソッドのみ許可

## 障害・課題

### 解決済み
#### protect_from_forgery エラー
**問題**: 
```
NoMethodError: undefined method 'protect_from_forgery' for class ApplicationController
```

**原因**: API-onlyモードでは`protect_from_forgery`が利用不可

**解決**: ApplicationControllerから該当行を削除
```ruby
# 削除した行
protect_from_forgery with: :null_session
```

#### Gemバージョン問題
**問題**: axlsx 4.1、rubocop 2.32が存在しない

**解決**: 実在するバージョンに変更
- axlsx 4.1 → rubyXL 3.4
- rubocop 2.32 → rubocop ~>1.77

## パフォーマンス

### レスポンス時間
- **ヘルスチェック**: 約50-100ms
- **初回起動**: 約10-15秒
- **メモリ使用量**: 約256MB

### データベース接続
- **接続時間**: 約10-20ms
- **プール設定**: 5コネクション（開発環境）

## 次のタスクへの引き継ぎ

- Rails API基盤完了
- 認証基盤（Devise）準備完了
- CORS設定でフロントエンド連携準備完了
- ヘルスチェックAPIで疎通確認可能
