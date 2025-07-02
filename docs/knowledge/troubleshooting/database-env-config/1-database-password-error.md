# DATABASE_PASSWORD エラーの解決

## 発生日時
2025年7月2日

## 問題の概要
Rails アプリケーション起動時に以下のエラーが発生：
```
Puma caught this error: Cannot load database configuration:
key not found: "DATABASE_PASSWORD" (KeyError)
```

## 原因分析
- `config/database.yml` の production 環境で `DATABASE_PASSWORD` 環境変数を参照している
- `docker-compose.dev.yml` では `DATABASE_URL` のみ設定されており、個別の環境変数が不足
- 開発環境と本番環境で環境変数の設定方法に不整合があった

## 解決方法
1. **環境変数の追加**: docker-compose.dev.yml に個別のデータベース環境変数を追加
2. **`.env` ファイルの導入**: ハードコーディングを避けるため環境変数ファイルを作成

### 変更内容
- docker-compose.dev.yml に以下の環境変数を追加：
  - `DATABASE_HOST=db`
  - `DATABASE_NAME=attendance_dev`
  - `DATABASE_USERNAME=dev`
  - `DATABASE_PASSWORD=devpass`
  - `DATABASE_PORT=5432`

## 学んだこと
- Docker Compose 環境では、Rails の database.yml で参照する全ての環境変数を明示的に設定する必要がある
- 開発環境でも本番環境と同様の環境変数構成にすることで、設定の一貫性を保てる
- `DATABASE_URL` と個別の環境変数の両方を設定することで、柔軟性を確保できる

## 関連ファイル
- `/backend/config/database.yml`
- `/docker-compose.dev.yml`

## 今後の改善点
- 環境変数のハードコーディングを避けるため `.env` ファイルの導入を検討
- 本番環境でも同様の環境変数設定を確認する必要がある
