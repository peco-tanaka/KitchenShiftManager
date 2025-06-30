# 3. Rails APIセットアップ - 設計判断記録

**作成日**: 2025年6月30日  
**Issue**: #1 開発基盤セットアップ  
**フェーズ**: Rails APIセットアップ  
**対応タスク**: Rails 7.2.2 API-onlyアプリケーションの構築と設定

## 主要な設計判断

### 1. Gemライブラリのバージョン調整

**判断内容**:
- **Excel生成**: 詳細設計書記載の `axlsx 4.1` → `rubyXL 3.4` に変更
- **Linter**: `rubocop 2.32` → `rubocop ~> 1.77` (利用可能な最新版)
- **認証**: `devise 4.9.4` (詳細設計書通り)
- **認可**: `pundit 2.3` (詳細設計書通り)

**理由**:
- **axlsx 4.1**: 存在しないバージョンのため、機能的に同等のrubyXLに変更
- **rubocop 2.32**: 存在しないバージョンのため、最新安定版1.77系に変更
- **後方互換性**: 既存の詳細設計で定義されたAPI仕様を変更せずに実装可能

**影響**:
- Excel生成機能の実装方法が変更（issue-05で詳細実装予定）
- Linter設定が1.x系の設定に準拠
- 詳細設計書の更新が必要（将来対応）

### 2. API-only モードの設定最適化

**判断内容**:
```ruby
# config/application.rb
config.api_only = true
config.middleware.use ActionDispatch::Cookies
config.middleware.use ActionDispatch::Session::CookieStore
```

**理由**:
- **Session Cookie認証**: Devise認証でのSession管理に必要
- **CSRF保護**: API認証セキュリティの確保
- **パフォーマンス**: 不要なViewレイヤー除去でメモリ使用量削減

**影響**:
- フロントエンドからの認証済みAPI呼び出し対応
- セキュアな認証機能の基盤確立
- 本番環境でのリソース使用量最適化

### 3. データベース設定の環境変数対応

**判断内容**:
```yaml
# config/database.yml production環境
production:
  adapter: postgresql
  encoding: unicode
  database: <%= ENV.fetch("DATABASE_NAME") { "kitchen_shift_manager_production" } %>
  username: <%= ENV.fetch("DATABASE_USERNAME") { "postgres" } %>
  password: <%= ENV.fetch("DATABASE_PASSWORD") { "" } %>
  host: <%= ENV.fetch("DATABASE_HOST") { "localhost" } %>
  port: <%= ENV.fetch("DATABASE_PORT") { "5432" } %>
```

**理由**:
- **セキュリティ**: 機密情報をコードベースから分離
- **デプロイ対応**: Render等のPaaSプラットフォーム対応
- **環境分離**: 開発・本番環境での設定値分離
- **フォールバック**: デフォルト値でローカル開発の簡素化

**影響**:
- 開発環境でRails server正常起動
- 本番デプロイ時の環境変数設定が簡素化
- セキュリティリスクの軽減

### 4. CORS設定の詳細化

**判断内容**:
```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Rails.env.development? ? 
      ["http://localhost:5173", "http://127.0.0.1:5173"] : 
      ENV.fetch("FRONTEND_ORIGIN", "")
    
    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true  # Session Cookie認証のため必要
  end
end
```

**理由**:
- **開発効率**: Vite開発サーバー（port:5173）からのアクセス許可
- **認証対応**: Session Cookie認証での`credentials: true`設定が必須
- **セキュリティ**: 本番環境では環境変数での厳格な制御
- **互換性**: ブラウザのCORS仕様完全対応

**影響**:
- フロントエンド開発時のAPI通信が正常動作
- Session認証の実装準備完了
- セキュアなクロスオリジン通信の確立

### 5. Docker環境でのボリュームマウント最適化

**判断内容**:
```yaml
# docker-compose.dev.yml
services:
  backend:
    volumes:
      - ./backend:/app  # プロジェクトルート全体ではなくbackendディレクトリのみ
```

**理由**:
- **ファイル構造**: プロジェクトルート全体をマウントすると、`backend/Gemfile`が正しくコンテナ内の`/app/Gemfile`として認識されない
- **整合性**: Dockerfileの`WORKDIR /app`とDockerfileの`COPY backend/ ./`設定との整合性確保
- **パフォーマンス**: 不要ファイルの同期除外

**影響**:
- コンテナ内でbundle installが正常実行
- Rails serverが正常起動
- ホットリロード機能が正常動作

### 6. ヘルスチェックエンドポイントの実装

**判断内容**:
```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    get 'health', to: 'health#check'
    get 'info', to: 'health#info'
  end
end

# app/controllers/api/health_controller.rb
class Api::HealthController < ApplicationController
  def check
    render json: { 
      status: 'ok', 
      timestamp: Time.current.iso8601,
      version: Rails.version
    }
  end
  
  def info
    render json: {
      application: 'Kitchen Shift Manager API',
      version: '1.0.0',
      environment: Rails.env,
      database: check_database_connection
    }
  end
end
```

**理由**:
- **監視対応**: 本番環境でのヘルスチェック機能提供
- **デバッグ支援**: API動作状況の可視化
- **統合テスト**: フロントエンドからのAPI接続確認
- **運用効率**: システム状態の迅速な把握

**影響**:
- フロントエンド開発時のAPI接続確認が容易
- 本番環境での監視・アラート設定が可能
- 障害発生時の迅速な原因特定

## Gemfile最終構成

### 本番環境Gem
```ruby
gem 'rails', '~> 7.2.2'
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'devise', '~> 4.9.4'
gem 'pundit', '~> 2.3'
gem 'rubyXL', '~> 3.4'
gem 'rack-cors'
gem 'bootsnap', '>= 1.4.4', require: false
```

### 開発・テスト環境Gem
```ruby
group :development, :test do
  gem 'rspec-rails', '~> 7.2'
  gem 'factory_bot_rails', '~> 7.5'
  gem 'debug', platforms: %i[mri windows]
end

group :development do
  gem 'rubocop', '~> 1.77', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end
```

## 技術選択の妥当性検証

### ✅ 成功した選択
1. **rubyXL 3.4**: Excel生成機能の安定した代替実装
2. **RuboCop 1.77**: 最新コード品質チェック機能
3. **Session Cookie認証**: セキュアで実装が容易
4. **API-only モード**: パフォーマンスとセキュリティの両立

### ⚠️ 注意点・今後の改善点
1. **Excel生成**: rubyXLの詳細設計書への反映
2. **セキュリティ**: 本番環境でのSecrets管理強化
3. **パフォーマンス**: 大量データ処理時の最適化検討

## 次のステップへの影響

### React フロントエンド セットアップ (次フェーズ)
- ✅ CORS設定完了により、API通信のベース準備完了
- ✅ ポート5173でのVite開発サーバー起動が前提
- ✅ ヘルスチェックAPI (`/api/health`) でAPI接続確認可能

### 認証機能実装 (issue-02)
- ✅ Devise 4.9.4の導入完了
- ✅ CORS設定でcredentials対応済み
- ✅ Session Cookie認証の基盤準備完了
- ✅ API-only設定でのセッション管理対応

### Excel出力機能 (issue-05)
- ✅ rubyXL 3.4導入完了
- ⚠️ 詳細設計書の更新が必要（axlsx → rubyXL）

## 確認完了事項

### 動作確認
- [x] Rails server起動確認 (localhost:3000)
- [x] データベース接続確認
- [x] ヘルスチェックAPI動作確認 (`/api/health`)
- [x] CORS設定動作確認
- [x] Docker環境での正常動作

### 未実装（次issue対応予定）
- [ ] 認証モデル・コントローラーの実装
- [ ] Pundit認可ポリシーの実装
- [ ] API Serializer実装
- [ ] エラーハンドリング統一化

---

**次のステップ**: React フロントエンドセットアップでのAPI通信基盤構築
