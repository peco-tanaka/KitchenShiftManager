# データベース設定のセキュリティ強化と環境変数管理

## 設計判断の背景

### 課題
- `backend/config/database.yml` にパスワード等の機密情報がハードコード
- Git管理から除外されているため、新規開発者のセットアップが困難
- Docker環境での環境変数管理が不統一

### 判断根拠
1. **セキュリティ向上**: 機密情報をコードベースから排除
2. **開発者体験向上**: テンプレート化により新規参加者のセットアップを簡素化
3. **環境の統一**: 開発・テスト・本番での設定管理方法を統一
4. **Docker環境との親和性**: コンテナベース開発での標準的なアプローチ

## 採用した解決策

### 1. database.ymlの環境変数化
```yaml
development:
  <<: *default
  database: <%= ENV.fetch("DATABASE_NAME") { "attendance_dev" } %>
  username: <%= ENV.fetch("DATABASE_USERNAME") { "dev" } %>
  password: <%= ENV.fetch("DATABASE_PASSWORD") { "devpass" } %>
  host: <%= ENV.fetch("DATABASE_HOST") { "localhost" } %>
  port: <%= ENV.fetch("DATABASE_PORT") { 5432 } %>
```

### 2. テンプレートファイルの導入
- `.env.development.template`
- `.env.test.template` 
- `.env.production.template`

### 3. Git管理方針の変更
- `database.yml`: Git管理対象（機密情報を含まないテンプレート）
- `.env.*`: Git管理除外（実際の機密情報を含む）
- `.env.*.template`: Git管理対象（サンプル値のみ）

### 4. Docker環境での統一
- docker-compose.dev.yml と docker-compose.prod.yml で同じ環境変数名を使用
- PostgreSQLコンテナとRailsアプリで環境変数を共有

## メリット
1. **セキュリティ**: 機密情報の漏洩リスクを排除
2. **保守性**: 環境ごとの設定変更が容易
3. **可搬性**: 異なる環境での動作が保証
4. **開発効率**: `cp`コマンド一つでセットアップ完了

## デメリット・注意点
1. **設定ミス**: 環境変数の設定漏れで接続エラーの可能性
2. **学習コスト**: 新規開発者への環境変数概念の説明が必要
3. **デバッグ**: 接続エラー時の原因特定がやや複雑

## 代替案検討
1. **Rails Credentials**: 暗号化された設定ファイル → 複雑性が増すため見送り
2. **dotenv-rails**: 環境変数管理gem → 依存関係増加を避けるため見送り
3. **設定ファイル分離**: 環境別設定ファイル → 管理が煩雑になるため見送り

## 今後の課題
1. 本番環境でのシークレット管理方法の確立
2. 環境変数のバリデーション機能追加検討
3. 設定値の暗号化要件があれば再検討

## 関連ドキュメント
- [実装ログ: データベース設定環境変数化](../logs/issue-01/database-env-config.md)
- [詳細設計.md: 環境設定](../../詳細設計.md)
