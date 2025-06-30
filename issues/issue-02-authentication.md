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

### データベース設計
- [ ] users テーブルのマイグレーション作成
- [ ] Devise 設定のカスタマイズ
- [ ] ロール enum の定義

### Devise セットアップ
- [ ] Devise gem の設定
- [ ] User モデルの設定
- [ ] 認証キーを employee_number に変更
- [ ] カスタムビューの作成

### 認可システム
- [ ] Pundit gem のセットアップ
- [ ] ApplicationPolicy の作成
- [ ] UserPolicy の作成
- [ ] Controller での認可チェック実装

### フロントエンド認証
- [ ] ログイン画面の実装
- [ ] ログアウト機能の実装
- [ ] 認証状態の管理
- [ ] ルートガード（React Router）の実装
- [ ] CSRF トークンの処理

### API エンドポイント
- [ ] POST /api/login
- [ ] POST /api/logout
- [ ] GET /api/me (現在のユーザー情報)

### セキュリティ対策
- [ ] CSRF 設定
- [ ] CORS 設定の調整
- [ ] Session 設定の最適化

### テスト
- [ ] 認証のテストケース
- [ ] 認可のテストケース
- [ ] セキュリティのテストケース

## 参考資料
- `/doc/詳細設計.md` の「認証・認可」
- `/doc/要件定義.md` の「利用者・権限」
- `/doc/詳細設計.md` の「DB設計」の users テーブル
