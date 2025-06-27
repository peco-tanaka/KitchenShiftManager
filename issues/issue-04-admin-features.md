# Issue #4: 管理機能（従業員・手当）

## 概要
`users` / `allowances` CRUD API ＋ 管理画面 UI、時給・手当登録機能を実装する。

## ゴール
manager が従業員情報・手当を追加／更新でき、打刻側に即反映される管理システムを構築する。

## スコープ

### 含まれる内容
- [ ] 従業員管理（CRUD）
- [ ] 手当管理（CRUD）
- [ ] 時給設定
- [ ] 管理画面UI
- [ ] 打刻データの手修正機能
- [ ] データの即時反映

### 含まれない内容
- 給与計算機能
- 勤怠データの大量インポート
- 従業員の写真管理

## 受入条件

- [ ] 管理者が従業員を追加・編集・削除できる
- [ ] 管理者が手当を設定・編集できる
- [ ] 時給が正しく設定・反映される
- [ ] 打刻データを手修正できる
- [ ] 変更が即座に勤怠計算に反映される
- [ ] 退職者を適切に処理できる
- [ ] 手当の月次設定ができる

## 技術仕様

### データベース設計
- users テーブル: 従業員マスタ
- allowances テーブル: 月次手当マスタ  
- user_allowances テーブル: 従業員別支給手当

### ユーザー情報
```ruby
# users table
employee_number: integer (unique)
encrypted_password: string
role: integer (employee: 0, manager: 1)
hourly_wage: integer
hired_on: date
terminated_on: date
```

### 手当情報
```ruby
# allowances table
allowance_type: string
month: date
name: string
amount: integer

# user_allowances table  
user_id: integer
allowance_id: integer
amount_override: integer
```

## タスク

### データベース実装
- [ ] allowances テーブルのマイグレーション
- [ ] user_allowances テーブルのマイグレーション
- [ ] モデルの関連定義
- [ ] バリデーション設定

### 従業員管理API
- [ ] GET /api/admin/users (従業員一覧)
- [ ] POST /api/admin/users (従業員作成)
- [ ] PUT /api/admin/users/:id (従業員更新)
- [ ] DELETE /api/admin/users/:id (従業員削除)
- [ ] GET /api/admin/users/:id (従業員詳細)

### 手当管理API
- [ ] GET /api/admin/allowances (手当一覧)
- [ ] POST /api/admin/allowances (手当作成)
- [ ] PUT /api/admin/allowances/:id (手当更新)
- [ ] DELETE /api/admin/allowances/:id (手当削除)
- [ ] POST /api/admin/user_allowances (従業員への手当割り当て)

### 打刻データ管理API
- [ ] GET /api/admin/punches (全打刻データ取得)
- [ ] PUT /api/admin/punches/:id (打刻修正)
- [ ] DELETE /api/admin/punches/:id (打刻削除)
- [ ] POST /api/admin/punches (打刻追加)

### 管理画面UI実装
- [ ] ダッシュボード画面
- [ ] 従業員管理画面
  - [ ] 従業員一覧表
  - [ ] 従業員追加フォーム
  - [ ] 従業員編集フォーム
  - [ ] 従業員詳細表示
- [ ] 手当管理画面
  - [ ] 手当一覧表
  - [ ] 手当追加フォーム
  - [ ] 従業員別手当設定
- [ ] 打刻データ管理画面
  - [ ] 打刻履歴検索・フィルター
  - [ ] 打刻修正フォーム
  - [ ] 勤怠データ一覧

### フォーム & バリデーション
- [ ] React Hook Form でのフォーム管理
- [ ] フロントエンド側バリデーション
- [ ] サーバー側バリデーション
- [ ] エラーメッセージ表示

### データ整合性
- [ ] 従業員削除時の打刻データ処理
- [ ] 手当変更時の過去データ処理
- [ ] 時給変更の適用タイミング

### UI/UX
- [ ] レスポンシブデザイン
- [ ] 確認ダイアログ
- [ ] 成功・エラー通知
- [ ] ローディング状態表示

### 権限制御
- [ ] 管理者のみアクセス可能
- [ ] Pundit ポリシーの実装
- [ ] API エンドポイントの保護

### テスト
- [ ] CRUD APIのテスト
- [ ] 権限制御のテスト
- [ ] データ整合性のテスト
- [ ] UI コンポーネントのテスト

## 参考資料
- `/doc/詳細設計.md` の「DB設計」
- `/doc/要件定義.md` の「管理機能」
- `/doc/詳細設計.md` の「API 仕様」
