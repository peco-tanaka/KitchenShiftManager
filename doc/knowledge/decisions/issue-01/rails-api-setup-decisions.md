# Rails API セットアップ - 設計判断記録

**作成日**: 2025年6月30日  
**Issue**: #1 開発基盤セットアップ  
**フェーズ**: Rails API セットアップ

## 主要な設計判断

### 1. Gemライブラリのバージョン調整

**判断内容**:
- **Excel生成**: 詳細設計書記載の `axlsx 4.1` → `rubyXL 3.4` に変更
- **Linter**: `rubocop 2.32` → `rubocop ~> 1.77` (利用可能な最新版)

**理由**:
- axlsx 4.1は存在せず、rubyXLが詳細設計書で更新済み
- rubocop 2.32は存在せず、1.77系が最新安定版

**影響**:
- Excel生成機能の実装方法が変更（issue-05で詳細実装）
- Linter設定が1.x系の設定に準拠

### 2. Docker環境でのボリュームマウント設定

**判断内容**:
```yaml
# 修正前
volumes:
  - .:/app

# 修正後  
volumes:
  - ./backend:/app
```

**理由**:
- プロジェクトルート全体をマウントすると、`backend/Gemfile`が正しくコンテナ内の`/app/Gemfile`として認識されない
- Dockerfileの`WORKDIR /app`とDockerfileの`COPY backend/ ./`の設定と整合性を取る必要

**影響**:
- コンテナ内でbundle installが正常実行
- Rails serverが正常起動
- ホットリロード機能が正常動作

### 3. データベース設定の環境変数対応

**判断内容**:
```yaml
# database.yml production環境
database: <%= ENV.fetch("DATABASE_NAME") { "kitchen_shift_manager_production" } %>
username: <%= ENV.fetch("DATABASE_USERNAME") { "postgres" } %>
password: <%= ENV.fetch("DATABASE_PASSWORD") { "" } %>
```

**理由**:
- 本番環境での必須環境変数にデフォルト値を提供
- 開発環境でのRails起動時エラーを回避
- Render デプロイ時の環境変数設定との互換性確保

**影響**:
- 開発環境でRails server正常起動
- 本番デプロイ時の環境変数設定が簡素化

### 4. CORS設定の詳細化

**判断内容**:
```ruby
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

**理由**:
- 開発環境でのVite開発サーバー（port:5173）からのアクセス許可
- Session Cookie認証での`credentials: true`設定が必須
- 本番環境では環境変数での制御

**影響**:
- フロントエンド開発時のAPI通信が正常動作
- Session認証の実装準備完了

## 次のステップへの影響

### React フロントエンド セットアップ (次フェーズ)
- CORS設定完了により、API通信のベース準備完了
- ポート5173でのVite開発サーバー起動が前提

### 認証機能実装 (issue-02)
- Devise 4.9.4の導入完了
- CORS設定でcredentials対応済み
- Session Cookie認証の基盤準備完了

## 確認事項

- [ ] rubyXL 3.4の詳細設計書への反映確認
- [ ] Gemバージョンの本番環境での動作確認（issue-06）
- [ ] データベース環境変数の本番設定手順確認（issue-06）
