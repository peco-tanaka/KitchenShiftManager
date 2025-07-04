# Phase1-認証基盤実装ログ

## 概要
Issue-02 Phase 1「バックエンド認証基盤」の実装作業記録。実行したコマンド、発生した問題、解決方法、動作確認結果を時系列で記録。

## 実装期間
- **開始**: 2025年7月3日
- **完了**: 2025年7月4日
- **作業時間**: 約6時間（問題解決含む）

---

## タスク実行履歴

### 1.1 Devise 初期設定

#### 作業内容
```bash
# Gemfile への Devise 追加
echo 'gem "devise", "~> 4.9"' >> Gemfile

# bundle install
docker compose exec backend bundle install

# Devise 初期化
docker compose exec backend rails generate devise:install
```

#### 実行結果
```
create  config/initializers/devise.rb
create  config/locales/devise.en.yml
```

#### 設定作業
1. **config/initializers/devise.rb** の設定:
   ```ruby
   config.authentication_keys = [:employee_number]
   config.password_length = 4..4
   config.case_insensitive_keys = [:employee_number]
   config.strip_whitespace_keys = [:employee_number]
   ```

2. **config/application.rb** でSession有効化:
   ```ruby
   config.session_store :cookie_store, key: '_kitchen_shift_session'
   config.middleware.use ActionDispatch::Cookies
   config.middleware.use ActionDispatch::Session::CookieStore
   ```

#### 結果
✅ **完了** - Devise基本設定とSession-Cookie設定が正常に動作

---

### 1.2 User モデル・マイグレーション作成

#### 作業内容
```bash
# Devise User モデル生成
docker compose exec backend rails generate devise User
```

#### 生成ファイル
```
invoke  active_record
create    db/migrate/20250703053019_devise_create_users.rb
create    app/models/user.rb
insert    config/routes.rb
```

#### マイグレーションファイル修正
元ファイルに以下カラムを追加：
```ruby
t.integer :employee_number, null: false
t.integer :role, null: false, default: 0
t.integer :hourly_wage, null: false
t.date :hired_on, null: false
t.date :terminated_on

add_index :users, :employee_number, unique: true
```

#### 追加カラム用マイグレーション
```bash
# 名前カラム追加
docker compose exec backend rails generate migration AddNameToUsers last_name:string first_name:string
```

#### マイグレーション実行
```bash
docker compose exec backend rails db:migrate
```

#### 実行結果
```
== 20250703053019 DeviseCreateUsers: migrating ================================
-- create_table(:users)
   -> 0.0234s
-- add_index(:users, :employee_number, {:unique=>true})
   -> 0.0089s
== 20250703053019 DeviseCreateUsers: migrated (0.0324s) ======================

== 20250703092803 AddNameToUsers: migrating ==================================
-- add_column(:users, :last_name, :string)
   -> 0.0008s
-- add_column(:users, :first_name, :string)
   -> 0.0005s
== 20250703092803 AddNameToUsers: migrated (0.0014s) ========================
```

#### 結果
✅ **完了** - User テーブル作成と必要カラムの追加完了

---

### 1.3 User モデル設定

#### モデル設定内容
```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { employee: 0, manager: 1 }

  validates :employee_number, presence: true, uniqueness: true,
    format: { with: /\A\d{4}\z/, message: '社員番号は4桁の数字で入力してください' }
  validates :password, format: { with: /\A\d{4}\z/, message: 'パスワードは4桁の数字で入力してください' }
  validates :last_name, :first_name, :hourly_wage, :hired_on, presence: true

  def self.find_for_database_authentication(warden_conditions)
    find_by(employee_number: warden_conditions[:employee_number])
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end
end
```

#### 動作確認
```bash
# Rails console での確認
docker compose exec backend rails console
```

```ruby
# モデル読み込み確認
User.new
# => #<User id: nil, employee_number: nil, role: "employee", ...>

# enum動作確認
User.roles
# => {"employee"=>0, "manager"=>1}
```

#### 結果
✅ **完了** - Userモデルの設定と動作確認完了

---

### 1.4 初期データ作成

#### 初期seeds.rb実装
```ruby
# db/seeds.rb
puts "start seed data creation..."

# Manager user
manager = User.find_or_create_by(employee_number: 1000) do |user|
  user.password = "1000"
  user.password_confirmation = "1000"
  user.last_name = "管理者"
  user.first_name = "店長"
  user.role = "manager"
  user.hourly_wage = 1500
  user.hired_on = Date.new(2025, 1, 1)
  user.terminated_on = nil
end
```

#### **⚠️ 問題発生**: employee_number null エラー

#### 実行結果（エラー）
```bash
docker compose exec backend rails db:seed
```

```
Error: Employee number can't be blank
Error: Employee number 社員番号は4桁の数字で入力してください
```

#### 問題分析
1. **型不整合**: DB型（integer）とバリデーション（string正規表現）の不一致
2. **find_or_create_by の動作**: 検索条件の属性が自動設定されない場合がある
3. **バリデーション設定**: 正規表現が文字列型を前提としている

#### 解決方法1: マイグレーションでの型変更
```bash
# employee_number を integer → string に変更
docker compose exec backend rails generate migration ChangeEmployeeNumberToStringInUsers
```

```ruby
# マイグレーション内容
class ChangeEmployeeNumberToStringInUsers < ActiveRecord::Migration[7.2]
  def up
    change_column :users, :employee_number, :string, null: false, using: 'employee_number::text'
  end

  def down
    change_column :users, :employee_number, :integer, null: false, using: 'employee_number::integer'
  end
end
```

#### 解決方法2: seeds.rb修正
```ruby
# 文字列での社員番号指定 + 明示的設定
manager = User.find_or_create_by(employee_number: "0001") do |user|
  user.employee_number = "0001"  # 明示的に設定
  user.password = "1000"
  user.password_confirmation = "1000"
  user.last_name = "管理者"
  user.first_name = "店長"
  user.role = "manager"
  user.hourly_wage = 1500
  user.hired_on = Date.new(2025, 1, 1)
  user.terminated_on = nil
end
```

#### マイグレーション実行
```bash
docker compose exec backend rails db:migrate
```

```
== 20250704090000 ChangeEmployeeNumberToStringInUsers: migrating ==============
-- change_column(:users, :employee_number, :string, {null: false, using: "employee_number::text"})
   -> 0.0182s
== 20250704090000 ChangeEmployeeNumberToStringInUsers: migrated (0.0183s) =====
```

#### seeds.rb 再実行
```bash
docker compose exec backend rails db:seed
```

#### 実行結果（成功）
```
start seed data creation...
Creating manager user...
Manager user created successfully: 管理者 店長 (Employee Number: 0001)
Creating development employee users...
Sample employee user created successfully: 山田 太郎 (Employee Number: 0002)

==================================================
🎉 Seed data creation completed successfully!
✅ All users created/verified: 2

📋 Expected user accounts:
  Manager: employee_number=0001, password=1000
  Sample Employee: employee_number=0002, password=1001

⚠️  Important: Change passwords in production environment!
==================================================
```

#### 最終動作確認
```bash
# Rails console での確認
docker compose exec backend rails console
```

```ruby
# 作成されたユーザー確認
User.all
# => [#<User id: 1, employee_number: "0001", role: "manager", ...>,
#     #<User id: 2, employee_number: "0002", role: "employee", ...>]

# 認証テスト
manager = User.find_by(employee_number: "0001")
manager.valid_password?("1000")
# => true

# ロール確認
manager.manager?
# => true
```

#### 結果
✅ **完了** - 初期データ作成とバリデーション問題の解決完了

---

## 発生した問題と解決

### 問題1: employee_number バリデーションエラー

#### 問題詳細
- seeds.rb実行時に「Employee number can't be blank」エラー
- バリデーション設定とDB型の不整合が原因

#### 解決アプローチ
1. **根本原因の特定**: integer型とstring型バリデーションの不一致
2. **型統一の決定**: 業務要件（先頭ゼロ対応）を考慮してstring型に統一
3. **マイグレーション実行**: 安全な型変更（USING句使用）
4. **seeds.rb修正**: 文字列指定と明示的な属性設定

#### 学んだこと
- ActiveRecord の find_or_create_by では明示的な属性設定が重要
- DB型とバリデーションの整合性確保の重要性
- 業務要件に応じた適切な型選択の必要性

### 問題2: 設計書との整合性

#### 問題詳細
- 詳細設計書では employee_number が integer型で記載
- 実装では string型に変更

#### 解決方法
- 詳細設計書の該当箇所を修正
- 変更理由をコメントで明記
- 設計変更の履歴として記録

---

## Tips・ベストプラクティス

### 1. マイグレーション作成時
```bash
# カラム型変更時はUSING句を使用
change_column :table_name, :column_name, :new_type, using: 'column_name::new_type'
```

### 2. find_or_create_by 使用時
```ruby
# 明示的な属性設定を推奨
Model.find_or_create_by(unique_key: value) do |record|
  record.unique_key = value  # 明示的に設定
  record.other_field = other_value
end
```

### 3. seeds.rb の冪等性確保
```ruby
# エラーハンドリングと詳細ログ
begin
  user = User.find_or_create_by!(conditions) do |u|
    # 設定
  end
  puts "✅ User created: #{user.name}"
rescue ActiveRecord::RecordInvalid => e
  puts "❌ Error: #{e.message}"
end
```

### 4. バリデーション設定
```ruby
# DB型と一致するバリデーション設定
validates :string_field, format: { with: /regex/ }
validates :integer_field, numericality: { in: range }
```

---

## 次フェーズへの引き継ぎ事項

### Phase 2（認証API実装）への準備状況
1. **✅ 完了事項**:
   - User モデルの安定動作確認済み
   - Session-Cookie設定の基盤整備完了
   - 初期データ（manager/employee）作成済み
   - employee_number文字列型での統一完了

2. **🔄 引き継ぎ事項**:
   - 社員番号は必ず文字列（"0001"形式）で処理
   - パスワードは4桁数字（"1000"形式）
   - ロール確認は `user.manager?` / `user.employee?` を使用
   - CSRF設定は `config/application.rb` で設定済み

3. **📝 注意事項**:
   - API設計時は employee_number を文字列として扱う
   - JSON レスポンスでも文字列型で統一
   - フロントエンド側も文字列処理を前提とする

---

## 関連ファイル変更履歴

### 作成ファイル
- `db/migrate/20250703053019_devise_create_users.rb`
- `db/migrate/20250703092803_add_name_to_users.rb`
- `db/migrate/20250704090000_change_employee_number_to_string_in_users.rb`
- `app/models/user.rb`

### 修正ファイル
- `Gemfile` (Devise 追加)
- `config/initializers/devise.rb`
- `config/application.rb`
- `db/seeds.rb`
- `docs/詳細設計.md` (employee_number型修正)

### 環境変更
- PostgreSQL テーブル構造の変更
- Session-Cookie設定の有効化
- 開発環境での初期データ投入

---

## 実装完了確認

### ✅ Phase 1 全タスク完了
1. **1.1 Devise 初期設定**: ✅ 完了
2. **1.2 User モデル・マイグレーション**: ✅ 完了
3. **1.3 User モデル設定**: ✅ 完了
4. **1.4 初期データ作成**: ✅ 完了

### 📊 動作確認済み項目
- [x] User モデルの CRUD 操作
- [x] employee_number での認証キー動作
- [x] role enum の動作
- [x] バリデーションの正常動作
- [x] seeds.rb の冪等性
- [x] PostgreSQL での型整合性

### 🚀 Phase 2 移行準備完了
Phase 1の全機能が正常動作し、Phase 2（認証API実装）への準備が整いました。

---

## 最終確認時間
- **確認日時**: 2025年7月4日 12:30
- **確認者**: GitHub Copilot
- **ステータス**: Phase 1 完了 ✅
