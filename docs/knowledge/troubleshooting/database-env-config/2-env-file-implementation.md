# .env ファイルによる環境変数管理の導入

## 実装日時
2025年7月2日

## 実装の背景
- docker-compose.dev.yml でのハードコーディングを解消
- セキュリティ向上（機密情報をコードから分離）
- 環境別設定の柔軟な管理
- 12-factor app の原則に従った設計

## 実装内容

### 1. .env ファイルの作成
プロジェクトルートに開発用環境変数ファイルを作成：

```bash
# データベース設定
DATABASE_HOST=db
DATABASE_NAME=attendance_dev
DATABASE_USERNAME=dev
DATABASE_PASSWORD=devpass
DATABASE_PORT=5432

# Rails設定
RAILS_ENV=development
RAILS_LOG_TO_STDOUT=1

# フロントエンド設定
VITE_API_BASE=http://localhost:3000
```

### 2. .env.production.example の作成
本番環境用のテンプレートファイル：

```bash
# データベース設定（本番環境用）
DATABASE_HOST=your-production-db-host
DATABASE_NAME=attendance_production
DATABASE_USERNAME=your-db-username
DATABASE_PASSWORD=your-secure-password
DATABASE_PORT=5432

# Rails設定
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=1
RAILS_SERVE_STATIC_FILES=1

# セキュリティ設定
SECRET_KEY_BASE=your-secret-key-base
```

### 3. docker-compose.dev.yml の修正
env_file ディレクティブを使用して .env ファイルを読み込み：

```yaml
backend:
  # ...existing config...
  env_file:
    - .env

frontend:
  # ...existing config...
  env_file:
    - .env
```

### 4. .gitignore の確認
機密情報を含む .env ファイルが既に .gitignore に追加されていることを確認済み。

## セキュリティ考慮事項
- `.env` ファイルは git にコミットしない
- `.env.example` ファイルでテンプレートを提供
- 本番環境では環境固有の値を設定

## 利点
1. **セキュリティ**: パスワードなどの機密情報をコードから分離
2. **柔軟性**: 環境ごとに異なる設定を簡単に管理
3. **保守性**: 設定変更時にコードを触らずに済む
4. **チーム開発**: .env.example で必要な環境変数を明示

## 注意点
- チームメンバーには .env ファイルの作成方法を共有する必要がある
- 本番環境では Render の環境変数設定を使用
- 機密情報は絶対に git にコミットしない

## 今後の展開
- 本番環境での環境変数設定の確認
- CI/CD パイプラインでの環境変数管理
- 環境変数のバリデーション機能の追加
