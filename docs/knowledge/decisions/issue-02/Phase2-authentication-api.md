# Phase 2: 認証API実装 - 設計判断

## 概要
Session-Cookie認証を使用した認証APIの実装において行った主要な設計判断と技術選択について記録。

## 設計判断

### 1. ActionController::API + Devise統合

**判断**: ActionController::APIでDeviseを使用するため、必要な機能のみを個別にinclude

**理由**:
- APIモードでは不要な機能を除外してパフォーマンスを向上
- Session-Cookie認証に必要な機能のみを追加
- セキュリティ面でのオーバーヘッドを最小化

**実装**:
```ruby
class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection
  protect_from_forgery with: :null_session
end
```

### 2. CSRF保護設定

**判断**: `protect_from_forgery with: :null_session`を採用

**理由**:
- APIエンドポイントではCSRFトークンが無効な場合にセッションをクリア
- フロントエンドとの統合時の柔軟性を確保
- セキュリティを保ちつつ、APIとしての使いやすさを両立

**代替案との比較**:
- `:exception`: APIには不適切（エラーページが表示される）
- `:reset_session`: セッション全体がリセットされるため不適切
- `:null_session`: APIに最適（無効な場合のみセッションをクリア）

### 3. 認証エンドポイント設計

**判断**: RESTfulなエンドポイント設計を採用

**実装エンドポイント**:
- `POST /api/login` - ログイン
- `POST /api/logout` - ログアウト  
- `GET /api/me` - 現在ユーザー取得

**理由**:
- HTTPメソッドの適切な使用
- 直感的で理解しやすいURL設計
- フロントエンドからの利用が容易

### 4. エラーレスポンス形式の統一

**判断**: 統一されたJSONレスポンス形式を採用

**形式**:
```json
{
  "status": "success|error",
  "message": "メッセージ",
  "user": { ... } // 成功時のみ
}
```

**理由**:
- フロントエンドでの処理が統一できる
- エラーハンドリングが簡素化される
- APIの一貫性を保持

### 5. ユーザー情報レスポンス設計

**判断**: セキュリティを考慮した必要最小限の情報のみ返却

**返却情報**:
- id, employee_number, last_name, first_name, role, hourly_wage, hired_on, terminated_on
- パスワードハッシュなどの機密情報は除外

**理由**:
- セキュリティリスクの最小化
- フロントエンドに必要な情報のみ提供
- API設計の原則（最小権限の原則）に準拠

## 技術的制約と考慮事項

### 1. ActionController::APIの制約

**制約**: デフォルトでセッション管理機能が無効

**対応**: 必要な機能を個別にinclude
- `ActionController::Cookies`
- `ActionController::RequestForgeryProtection`

### 2. Deviseヘルパーメソッドの利用

**使用メソッド**:
- `user_signed_in?`: 認証状態の確認
- `current_user`: 現在のユーザー取得
- `sign_in(user)`: セッション開始
- `sign_out(user)`: セッション終了

**注意点**: API modeでもDeviseのヘルパーメソッドは正常に動作することを確認

### 3. セッション設定

**設定**: Rails標準のセッション設定を使用
- Cookie-based session
- SameSite=Lax（CORS対応）
- Secure flag（本番環境）

## 変更履歴

| 日付 | 変更内容 | 理由 |
|------|----------|------|
| 2025-07-07 | ApplicationControllerにDevise機能追加 | Session-Cookie認証の有効化 |
| 2025-07-07 | CSRF保護設定を追加 | セキュリティ強化 |
| 2025-07-07 | SessionsController実装 | 認証APIエンドポイントの提供 |
| 2025-07-07 | エラーハンドリング統一 | API一貫性の向上 |

## 今後の課題

1. **テストケースの追加**: RSpecによるリクエストテストの実装
2. **セキュリティ強化**: レート制限、ブルートフォース対策
3. **ログ機能**: 認証イベントのログ記録
4. **セッション管理**: セッションタイムアウト設定の最適化
