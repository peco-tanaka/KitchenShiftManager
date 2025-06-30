# Rails API セットアップ - 実装履歴

**作成日**: 2025年6月30日  
**Issue**: #1 開発基盤セットアップ  
**作業者**: GitHub Copilot  

## 実装完了項目

### ✅ Rails new でAPI-onlyアプリ作成
**実行コマンド**:
```bash
docker run --rm -v "$(pwd)/backend:/app" -w /app ruby:3.4.4 bash -c "gem install rails -v 7.2.2 && rails new . --api --database=postgresql --skip-git --skip-bundle"
```

**成果物**:
- Rails 7.2.2.1 API-onlyアプリケーション
- PostgreSQL対応のデータベース設定
- API専用の最小限ファイル構成

### ✅ Gemfile の設定（必要な gem の追加）
**追加したgem**:
```ruby
# 認証・認可
gem "devise", "~> 4.9.4"
gem "pundit", "~> 2.3"

# Excel生成
gem "rubyXL", "~> 3.4"

# CORS設定
gem "rack-cors"

# 開発・テスト環境
gem "rspec-rails", "~> 8.0"
gem "factory_bot_rails", "~> 6.5"
gem "rubocop", "~> 1.77"
gem "dotenv-rails", "~> 3.1"
```

**bundle install結果**:
- 全102 gems正常インストール
- Gemfile.lock生成完了

### ✅ データベース設定
**修正ファイル**: `config/database.yml`

**主な設定**:
```yaml
development:
  adapter: postgresql
  database: kitchen_shift_manager_development
  username: postgres
  password: postgres
  host: <%= ENV.fetch("DATABASE_HOST") { "localhost" } %>
  port: 5432

test:
  adapter: postgresql
  database: kitchen_shift_manager_test
  username: postgres
  password: postgres
  host: <%= ENV.fetch("DATABASE_HOST") { "localhost" } %>
  port: 5432

production:
  adapter: postgresql
  database: <%= ENV.fetch("DATABASE_NAME") { "kitchen_shift_manager_production" } %>
  username: <%= ENV.fetch("DATABASE_USERNAME") { "postgres" } %>
  password: <%= ENV.fetch("DATABASE_PASSWORD") { "" } %>
  host: <%= ENV.fetch("DATABASE_HOST") { "localhost" } %>
  port: <%= ENV.fetch("DATABASE_PORT") { 5432 } %>
```

### ✅ CORS設定
**修正ファイル**: `config/initializers/cors.rb`

**設定内容**:
- 開発環境: localhost:5173（Vite）からのアクセス許可
- credentials: true（Session Cookie認証対応）
- 本番環境: 環境変数での制御

### ✅ 基本的なヘルスチェックエンドポイント
**実装ファイル**:
- `config/routes.rb`: ルーティング設定
- `app/controllers/application_controller.rb`: ルートエンドポイント
- `app/controllers/api/health_controller.rb`: ヘルスチェック専用

**エンドポイント**:
- `GET /`: アプリケーション基本情報
- `GET /api/health`: 詳細ヘルスチェック（DB接続含む）
- `GET /up`: Rails標準ヘルスチェック

### ✅ Railsサーバー接続確認
**起動確認**:
- PostgreSQL: ✅ 正常起動（port:5432）
- Rails API: ✅ 正常起動（port:3000）
- エンドポイント応答確認: ✅ 完了

## 発生した問題と解決策

### 問題1: Docker環境でのGemfile not found エラー
**症状**: `Could not locate Gemfile`
**原因**: `docker-compose.dev.yml`のvolumes設定で`.:/app`が不適切
**解決策**: `./backend:/app`に変更

### 問題2: gemバージョン不整合
**症状**: `axlsx 4.1`, `rubocop 2.32`が存在しない
**原因**: 詳細設計書のバージョンが利用不可
**解決策**: 利用可能な最新安定版に変更

### 問題3: データベース環境変数エラー
**症状**: `DATABASE_PASSWORD`環境変数が見つからない
**原因**: 本番環境設定で必須パラメータにデフォルト値なし
**解決策**: ENV.fetchにデフォルト値追加

## Tips・ノウハウ

### Docker開発環境でのコマンド実行
```bash
# 一回限りのコマンド実行
docker run --rm -v "$(pwd)/backend:/app" -w /app ruby:3.4.4 [command]

# 特定サービスのみ起動
docker compose -f docker-compose.dev.yml up db
docker compose -f docker-compose.dev.yml up backend

# ログ確認
docker logs [container_id]
```

### Rails API開発時の確認ポイント
1. **Gemfile.lock**: 本番環境との整合性確保のため必須
2. **CORS設定**: 開発時の credentials: true 設定重要
3. **環境変数**: デフォルト値設定で開発体験向上
4. **ヘルスチェック**: インフラ監視との連携を考慮

### Bundle install時の注意点
- Ruby 3.4.4での互換性確認
- gem依存関係の競合確認
- ネイティブ拡張のコンパイル時間考慮

## 次ステップの準備状況

### React フロントエンド セットアップ準備
- ✅ CORS設定完了（port:5173対応）
- ✅ API ベースエンドポイント稼働
- ⏳ frontendディレクトリは空（次タスク）

### 認証機能実装準備
- ✅ Devise 4.9.4導入完了
- ✅ Session Cookie対応CORS設定完了
- ⏳ Devise設定・マイグレーション未実施

### テスト環境準備
- ✅ RSpec-Rails 7.1導入完了
- ✅ FactoryBot-Rails 6.5導入完了
- ⏳ RSpec初期設定未実施

## 動作確認完了事項

- [x] Rails API server起動確認
- [x] PostgreSQL接続確認
- [x] ヘルスチェックエンドポイント応答確認
- [x] CORS設定動作確認（preflight request対応）
- [x] Docker Compose開発環境動作確認
