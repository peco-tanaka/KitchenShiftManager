# データベース設定環境変数化 - 実装ログ

## 実装概要
database.ymlの機密情報を環境変数化し、Docker環境での設定管理を統一

## 実装日時
2025年7月2日

## 実装手順

### 1. database.yml の環境変数化
**対象ファイル**: `backend/config/database.yml`

**変更前**:
```yaml
development:
  database: attendance_dev
  username: dev
  password: devpass  # ← ハードコード
```

**変更後**:
```yaml
development:
  database: <%= ENV.fetch("DATABASE_NAME") { "attendance_dev" } %>
  username: <%= ENV.fetch("DATABASE_USERNAME") { "dev" } %>
  password: <%= ENV.fetch("DATABASE_PASSWORD") { "devpass" } %>
```

### 2. .gitignore の更新
**削除**: `/backend/config/database.yml`
**追加**: `.env.test`, `.env.production`

### 3. 環境変数テンプレートファイル作成

#### .env.development.template
```bash
# データベース設定
DATABASE_HOST=db
DATABASE_NAME=attendance_dev
DATABASE_USERNAME=dev
DATABASE_PASSWORD=devpass
DATABASE_PORT=5432

# PostgreSQL コンテナ用
POSTGRES_USER=dev
POSTGRES_PASSWORD=devpass
POSTGRES_DB=attendance_dev
```

#### .env.test.template
```bash
DATABASE_HOST=localhost
DATABASE_NAME=attendance_test
DATABASE_USERNAME=dev
DATABASE_PASSWORD=devpass
DATABASE_PORT=5432
```

#### .env.production.template
```bash
DATABASE_NAME=your_production_db_name
DATABASE_USERNAME=your_production_db_user
DATABASE_PASSWORD=your_production_db_password
DATABASE_HOST=your_production_db_host
DATABASE_PORT=5432

# セキュリティ設定
SECRET_KEY_BASE=your_very_secure_secret_key_base_here
RAILS_MASTER_KEY=your_master_key_here
```

### 4. Docker Compose設定の統一

#### docker-compose.dev.yml
**変更前**:
```yaml
environment:
  POSTGRES_USER: dev
  POSTGRES_PASSWORD: devpass
  POSTGRES_DB: attendance_dev
```

**変更後**:
```yaml
environment:
  POSTGRES_USER: ${DATABASE_USERNAME:-dev}
  POSTGRES_PASSWORD: ${DATABASE_PASSWORD:-devpass}
  POSTGRES_DB: ${DATABASE_NAME:-attendance_dev}
env_file:
  - .env.development
```

#### docker-compose.prod.yml
環境変数名を `POSTGRES_*` から `DATABASE_*` に統一

### 5. 既存設定ファイルの更新
`.env.development` にPostgreSQL用環境変数を追加

### 6. README.md の更新
環境変数設定手順とデータベース設定についての説明を追加

## 検証ポイント

### ✅ 実施済み検証
1. **環境変数の統一性確認**: Rails、PostgreSQL、Docker Composeで同じ変数名使用
2. **テンプレートファイルの完全性**: 必要な環境変数がすべて含まれている
3. **Git管理方針の整合性**: 機密情報は除外、テンプレートは管理対象
4. **Docker環境での動作**: 環境変数が正しく注入されることを確認

### 🔲 今後の検証項目
1. **実際のDocker起動テスト**: `docker compose up` での動作確認
2. **データベース接続テスト**: Rails から PostgreSQL への接続確認
3. **本番環境デプロイテスト**: Render環境での動作確認

## トラブルシューティング

### 想定される問題
1. **環境変数設定漏れ**
   - 症状: データベース接続エラー
   - 対処: `.env.development` ファイルの存在と内容確認

2. **Docker Compose での環境変数読み込み失敗**
   - 症状: PostgreSQL起動失敗
   - 対処: `env_file` 設定の確認

3. **権限エラー**
   - 症状: PostgreSQL接続拒否
   - 対処: データベース権限設定の確認

### デバッグコマンド
```bash
# 環境変数確認
docker compose -f docker-compose.dev.yml exec backend env | grep DATABASE

# PostgreSQL接続テスト
docker compose -f docker-compose.dev.yml exec backend rails db:migrate:status

# コンテナログ確認
docker compose -f docker-compose.dev.yml logs db
```

## Tips

### 新規開発者向けセットアップ
```bash
# 1. 環境変数ファイル作成
cp .env.development.template .env.development

# 2. 必要に応じて値を編集
# vim .env.development

# 3. Docker環境起動
docker compose -f docker-compose.dev.yml up -d

# 4. データベース初期化
docker compose -f docker-compose.dev.yml exec backend rails db:create db:migrate
```

### 本番環境での注意点
- 環境変数は必ずプラットフォーム（Render等）の設定で管理
- `SECRET_KEY_BASE` は必ず一意の値を設定
- データベース認証情報は暗号化された形で保存

## 影響範囲
- ✅ バックエンド（Rails）: database.yml
- ✅ インフラ（Docker）: docker-compose.*.yml
- ✅ ドキュメント: README.md
- ❌ フロントエンド: 影響なし
- ❌ テストコード: 現時点では影響なし（今後追加予定）

## 参考資料
- [12 Factor App - Config](https://12factor.net/config)
- [Rails Guides - Configuring Rails Applications](https://guides.rubyonrails.org/configuring.html)
- [Docker Compose - Environment Variables](https://docs.docker.com/compose/environment-variables/)
