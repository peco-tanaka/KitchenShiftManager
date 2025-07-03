# Issue #2: 認証・ロール制御

## 概要
Devise（社員番号＋PW）実装、Session-Cookie 認証、Pundit で `employee` と `manager` の権限制御を実装する。

## ゴール
manager だけ `/admin/*` へアクセス可能、employee は打刻 API のみ利用可能な認証・認可システムを構築する。

## スコープ

### 含まれる内容
- [ ] Devise による認証システム
- [ ] 社員番号4桁 + パスワード4桁での認証
- [ ] Session-Cookie 認証
- [ ] Pundit による認可システム
- [ ] employee / manager ロール制御
- [ ] ログイン・ログアウト画面
- [ ] CSRF 対策

### 含まれない内容
- パスワードリセット機能（管理者が手動で対応）
- 2要素認証
- OAuth連携

## 受入条件

- [ ] 社員番号4桁 + パスワード4桁でログインできる
- [ ] Session-Cookie でログイン状態が維持される
- [ ] manager ロールは管理画面にアクセスできる
- [ ] employee ロールは打刻画面のみアクセスできる
- [ ] 認証されていないユーザーは適切にリダイレクトされる
- [ ] CSRF トークンが正しく動作する
- [ ] ログアウト機能が動作する

## 技術仕様

### 認証
- Devise 4.9.4
- 認証キー: `employee_number` (社員番号)
- パスワード: BCrypt ハッシュ化
- Session Cookie: `SameSite=Lax; Secure; HttpOnly`

### 認可
- Pundit 2.3
- ロール: `enum role: { employee: 0, manager: 1 }`

### セキュリティ
- CSRF 保護: `protect_from_forgery with: :exception`
- Secure Headers
- HTTPS 強制（本番環境）

## タスク

### Phase 1: バックエンド認証基盤（高優先度）

#### 1.1 Devise 初期設定
- [x] Devise の初期化実行 (`rails generate devise:install`)
- [x] `config/initializers/devise.rb` の基本設定
- [x] Session Cookie 設定の追加

#### 1.2 User モデル・マイグレーション作成
- [x] Devise User モデル生成 (`rails generate devise User`)
- [x] マイグレーションファイルのカスタマイズ
  - [x] `employee_number` カラム追加（integer, unique, not null）
  - [x] `role` カラム追加（integer, default: 0, not null）
  - [x] `hourly_wage` カラム追加（integer, not null）
  - [x] `hired_on` カラム追加（date, not null）
  - [x] `terminated_on` カラム追加（date, nullable）
- [x] データベースマイグレーション実行

#### 1.3 User モデル設定
- [ ] 認証キーを `employee_number` に変更
- [ ] `role` enum の定義（`{ employee: 0, manager: 1 }`）
- [ ] バリデーション追加
  - [ ] `employee_number` の4桁数字制約
  - [ ] `password` の4桁数字制約
  - [ ] その他必須項目のバリデーション
- [ ] Association の定義

#### 1.4 初期データ作成
- [ ] seeds.rb でmanager ユーザー作成
- [ ] 初期データ投入の動作確認

### Phase 2: 認証API実装（高優先度）

#### 2.1 認証コントローラー作成
- [ ] `Api::SessionsController` 作成
- [ ] ログインエンドポイント実装 (`POST /api/login`)
- [ ] ログアウトエンドポイント実装 (`POST /api/logout`)
- [ ] 現在ユーザー取得実装 (`GET /api/me`)

#### 2.2 ApplicationController 基盤設定
- [ ] CSRF保護の設定 (`protect_from_forgery with: :exception`)
- [ ] Session設定の最適化
- [ ] API用エラーハンドリング

#### 2.3 ルーティング設定
- [ ] `config/routes.rb` に認証API追加
- [ ] 動作確認（curl またはPostmanでテスト）

### Phase 3: 認可システム（中優先度）

#### 3.1 Pundit 設定
- [ ] Pundit 初期化 (`rails generate pundit:install`)
- [ ] `ApplicationPolicy` の基本設定
- [ ] `ApplicationController` にPundit include

#### 3.2 ポリシー作成
- [ ] `UserPolicy` 作成
- [ ] manager/employee の権限定義
- [ ] admin機能への制限実装

#### 3.3 コントローラー保護
- [ ] 各コントローラーでの認可チェック実装
- [ ] `before_action` での認証・認可確認

### Phase 4: フロントエンド認証（中優先度）

#### 4.1 認証状態管理
- [ ] 認証コンテキスト（AuthContext）作成
- [ ] `useAuth` カスタムフック実装
- [ ] CSRF トークン取得・管理機能

#### 4.2 ログイン画面実装
- [ ] ログインフォームコンポーネント作成
- [ ] バリデーション機能（4桁数字制約）
- [ ] エラーメッセージ表示
- [ ] ログイン成功時のリダイレクト

#### 4.3 ルーティング保護
- [ ] `ProtectedRoute` コンポーネント作成
- [ ] 管理者専用ルート保護
- [ ] 未認証時のリダイレクト処理
- [ ] React Router設定更新

#### 4.4 ログアウト機能
- [ ] ログアウトボタン・機能実装
- [ ] 認証状態のクリア
- [ ] ログアウト後のリダイレクト

### Phase 5: セキュリティ強化・最適化（低優先度）

#### 5.1 セキュリティ設定
- [ ] CORS設定の調整（認証Cookie対応）
- [ ] Session設定の最適化
- [ ] Secure Headers設定

#### 5.2 テストケース作成
- [ ] User モデルのテスト
- [ ] 認証APIのリクエストテスト
- [ ] 認可ポリシーのテスト
- [ ] フロントエンド認証フローのテスト

## 参考資料
- `/doc/詳細設計.md` の「認証・認可」
- `/doc/要件定義.md` の「利用者・権限」
- `/doc/詳細設計.md` の「DB設計」の users テーブル
