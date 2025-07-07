# Phase 2: 認証API実装 - 実装ログ

## 実装概要
Session-Cookie認証を使用した認証APIシステムの実装。Devise 4.9.4とActionController::APIを統合し、RESTfulな認証エンドポイントを提供。

## 実装手順

### Step 1: ApplicationController基盤設定

**実装内容**:
```ruby
class ApplicationController < ActionController::API
  # Deviseの機能を有効化（Session-Cookie認証用）
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection
  
  # CSRF保護を有効化
  protect_from_forgery with: :null_session
  
  # API共通設定
  before_action :set_default_response_format
end
```

**実装のポイント**:
- ActionController::APIでDeviseを使用するための設定
- CSRF保護をAPIに適した設定で有効化
- 共通的なJSON format設定

### Step 2: 認証ヘルパーメソッド実装

**実装内容**:
```ruby
# 認証が必要なエンドポイント用のbefore_action
def authenticate_user!
  unless user_signed_in?
    render json: {
      status: 'error',
      message: '認証が必要です。ログインしてください。'
    }, status: :unauthorized
  end
end

# 管理者権限が必要なエンドポイント用のbefore_action
def ensure_manager!
  authenticate_user!
  unless current_user&.manager?
    render json: {
      status: 'error',
      message: '管理者権限が必要です。'
    }, status: :forbidden
  end
end
```

**実装のポイント**:
- 統一されたエラーレスポンス形式
- 適切なHTTPステータスコード（401, 403）の使用
- 認証チェック後の認可チェック実装

### Step 3: SessionsController実装

**実装内容**:
```ruby
module Api
  class SessionsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create, :destroy, :show]

    # POST /api/login
    def create
      user = User.find_by(employee_number: login_params[:employee_number])
      
      if user&.valid_password?(login_params[:password])
        sign_in(user)
        render json: {
          status: 'success',
          message: 'ログインしました',
          user: user_response(user)
        }, status: :ok
      else
        render json: {
          status: 'error',
          message: '社員番号またはパスワードが正しくありません'
        }, status: :unauthorized
      end
    end

    # POST /api/logout  
    def destroy
      if user_signed_in?
        sign_out(current_user)
        render json: {
          status: 'success',
          message: 'ログアウトしました'
        }, status: :ok
      else
        render json: {
          status: 'error',
          message: 'ログインしていません'
        }, status: :unauthorized
      end
    end

    # GET /api/me
    def show
      if user_signed_in?
        render json: {
          status: 'success',
          user: user_response(current_user)
        }, status: :ok
      else
        render json: {
          status: 'error',
          message: '認証が必要です'
        }, status: :unauthorized
      end
    end
  end
end
```

**実装のポイント**:
- Strong Parametersの使用
- Deviseヘルパーメソッド（sign_in, sign_out）の活用
- 統一されたJSONレスポンス形式
- 適切なHTTPステータスコードの返却

### Step 4: ルーティング設定

**実装内容**:
```ruby
Rails.application.routes.draw do
  devise_for :users
  
  namespace :api do
    # 認証用エンドポイント
    post "login", to: "sessions#create"
    post "logout", to: "sessions#destroy"
    get "me", to: "sessions#show"
  end
end
```

**実装のポイント**:
- RESTfulなURL設計
- 明確で理解しやすいエンドポイント名
- APIのバージョニングを考慮したnamespace設計

## 動作確認結果

### テスト実行結果

1. **認証前のユーザー情報取得**:
   ```bash
   curl -X GET http://localhost:3000/api/me
   # 期待結果: {"status":"error","message":"認証が必要です"}
   # 実際結果: ✅ {"status":"error","message":"認証が必要です"}
   ```

2. **ログイン API（正しい認証情報）**:
   ```bash
   curl -X POST http://localhost:3000/api/login \
     -H "Content-Type: application/json" \
     -d '{"user":{"employee_number":"0001","password":"1000"}}' \
     -c cookies.txt
   # 期待結果: ログイン成功とユーザー情報返却
   # 実際結果: ✅ {"status":"success","message":"ログインしました","user":{"id":1,"employee_number":"0001","last_name":"管理者","first_name":"店長","role":"manager","hourly_wage":1500,"hired_on":"2025-01-01","terminated_on":null}}
   ```

3. **認証後のユーザー情報取得**:
   ```bash
   curl -X GET http://localhost:3000/api/me \
     -H "Content-Type: application/json" \
     -b cookies.txt
   # 期待結果: ユーザー情報の正常返却
   # 実際結果: ✅ {"status":"success","user":{"id":1,"employee_number":"0001","last_name":"管理者","first_name":"店長","role":"manager","hourly_wage":1500,"hired_on":"2025-01-01","terminated_on":null}}
   ```

4. **ログアウト API**:
   ```bash
   curl -X POST http://localhost:3000/api/logout \
     -H "Content-Type: application/json" \
     -b cookies.txt -c cookies.txt
   # 期待結果: ログアウト成功
   # 実際結果: ✅ {"status":"success","message":"ログアウトしました"}
   ```

5. **ログアウト後の認証状態確認**:
   ```bash
   curl -X GET http://localhost:3000/api/me \
     -H "Content-Type: application/json" \
     -b cookies.txt
   # 期待結果: 認証エラー
   # 実際結果: ✅ {"status":"error","message":"認証が必要です"}
   ```

### 動作確認総合評価: ✅ **全て正常動作**

**確認されたセッション管理の動作**:
- Session-Cookie認証が正常に機能
- ログイン時のセッション開始
- ログアウト時のセッション終了とクリア
- 認証状態の適切な管理

## 障害対応履歴

### 問題1: CSRF保護エラー

**症状**: 
```
ArgumentError: Before process_action callback :verify_authenticity_token has not been defined
```

**原因**: 
- ActionController::APIではCSRF保護機能がデフォルトで無効
- `skip_before_action :verify_authenticity_token`を定義前に実行

**解決策**:
- ApplicationControllerで`protect_from_forgery with: :null_session`を設定
- CSRF保護を有効化してから、必要に応じてskip

**学習ポイント**: 
- ActionController::APIでDeviseを使用する際の初期設定の重要性
- include順序とbefore_action設定のタイミング

### 問題2: 動作確認時のCookie管理

**症状**: 
- ログアウト後も認証状態が維持される誤解
- 古いCookieファイルによる不正確なテスト結果

**原因**: 
- curlの`-b cookies.txt`オプションが古いセッション情報を参照
- ログアウト時にCookieファイルの更新が不完全

**解決策**:
- テスト前に`rm -f cookies.txt`でCookieファイルを削除
- ログアウト時に`-c cookies.txt`オプションでCookie更新を確実に実行
- 正しいパスワード（1000）の使用

**学習ポイント**: 
- Session-Cookie認証のテスト方法の重要性
- Cookieファイル管理の注意点
- 段階的なテスト実行の必要性

## Tips & ベストプラクティス

### 1. セキュリティ関連

- **パスワード確認**: `user&.valid_password?`で安全ナビゲーション演算子を使用
- **Strong Parameters**: 必要最小限のパラメータのみ許可
- **レスポンス情報制限**: 機密情報（パスワードハッシュ等）は返却しない

### 2. エラーハンドリング

- **統一されたレスポンス形式**: status、messageキーを常に含める
- **適切なHTTPステータス**: 401（認証エラー）、403（認可エラー）を正しく使い分け
- **ユーザーフレンドリーなメッセージ**: 技術的詳細を隠し、分かりやすいメッセージを提供

### 3. API設計

- **RESTful設計**: HTTPメソッドを適切に使用
- **一貫したURL構造**: `/api/`プレフィックスでAPI統一
- **バージョニング考慮**: 将来のAPI更新を見据えた設計

## 次のステップ

### Phase 3: 認可システム（Pundit）
- [ ] Pundit gemの設定
- [ ] ApplicationPolicyの実装
- [ ] UserPolicyの作成
- [ ] ロール別アクセス制御の実装

### 追加実装項目
- [ ] RSpecによるテストケース作成
- [ ] ログ機能の実装
- [ ] セッションタイムアウト設定
- [ ] レート制限機能
