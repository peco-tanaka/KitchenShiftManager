# Phase1-認証基盤の設計判断記録

## 概要
Issue-02 Phase 1における認証システムの基盤設計で行った主要な技術的判断と、その根拠・影響を記録する。

## 実装期間
- 開始: 2025年7月3日
- 完了: 2025年7月4日

---

## 主要な設計判断

### 1. employee_number のデータ型選択

#### 判断内容
`employee_number` カラムを **integer型からstring型に変更**

#### 判断根拠
1. **業務要件への適合**:
   - 飲食店では先頭ゼロ付きの社員番号（"0001", "0123"）が一般的
   - 4桁固定での統一的な表示が求められる
   - 視覚的に分かりやすい連番管理

2. **技術的一貫性**:
   - バリデーション（正規表現）とDB型の整合性確保
   - ActiveRecordでの型変換エラー回避
   - find_or_create_byメソッドでの安定動作

3. **拡張性**:
   - 将来的な社員番号体系変更への対応
   - 店舗コード付き社員番号（例: "A001"）への拡張可能性

#### 影響・トレードオフ
- **正の影響**:
  - バリデーションエラーの根本解決
  - 業務要件との完全適合
  - 先頭ゼロ表示の自然なサポート

- **技術的考慮事項**:
  - 数値演算が不要（社員番号は識別子として使用）
  - 文字列でも数値順ソートが正常動作
  - APIでのJSON送受信でも型が統一

### 2. Devise認証設定方針

#### 判断内容
**Session-Cookie認証 + 社員番号認証キー** の採用

#### 判断根拠
1. **要件適合**:
   - 詳細設計書でSession-Cookie認証が指定済み
   - 社員番号4桁 + パスワード4桁の認証仕様
   - API-onlyモードでもSession対応が必要

2. **セキュリティ**:
   - CSRF保護との組み合わせ
   - HttpOnly, Secure, SameSite=Lax設定
   - BCryptによるパスワードハッシュ化

3. **開発効率**:
   - Deviseの豊富な機能活用
   - 標準的なRails認証パターン
   - 将来的な機能拡張への対応

#### 設定内容
```ruby
# config/initializers/devise.rb
config.authentication_keys = [:employee_number]
config.password_length = 4..4
config.case_insensitive_keys = [:employee_number]
config.strip_whitespace_keys = [:employee_number]

# config/application.rb (API-onlyでSession有効化)
config.session_store :cookie_store, key: '_kitchen_shift_session'
config.middleware.use ActionDispatch::Cookies
config.middleware.use ActionDispatch::Session::CookieStore
```

### 3. Userモデル設計方針

#### 判断内容
**role enum + 必要最小限のバリデーション** での実装

#### 判断根拠
1. **シンプルな権限制御**:
   - 2つのロール（employee: 0, manager: 1）で充分
   - 将来的なロール追加への拡張性確保
   - Punditとの連携を考慮

2. **データ整合性**:
   - 必須項目のバリデーション設定
   - 一意制約（employee_number）の確保
   - 適切な長さ制限（社員番号4桁、パスワード4桁）

3. **飲食店業務適合**:
   - 時給（hourly_wage）の管理
   - 雇用期間（hired_on, terminated_on）の追跡
   - 将来的な勤怠計算への対応

#### バリデーション設計
```ruby
validates :employee_number, presence: true, uniqueness: true,
  format: { with: /\A(?!0000)\d{4}\z/, message: '社員番号は0000以外の4桁の数字で入力してください' }
validates :password, format: { with: /\A\d{4}\z/, message: 'パスワードは4桁の数字で入力してください' }
validates :last_name, :first_name, :hourly_wage, :hired_on, presence: true
```

### 4. 初期データ戦略

#### 判断内容
**冪等性を重視したseeds.rb実装**

#### 判断根拠
1. **開発効率**:
   - 繰り返し実行可能な初期データ投入
   - 開発環境のリセット作業の簡素化
   - チーム開発での環境統一

2. **運用安全性**:
   - 本番環境での誤実行防止
   - 既存データの保護
   - エラーハンドリングによる安全な実行

3. **テスト支援**:
   - 一貫したテストデータ
   - 認証テストの基盤データ提供

#### 実装方針
```ruby
# find_or_create_by での冪等性確保
# 明示的な属性設定による安全性向上
# 実行結果の詳細ログ出力
```

---

## 技術的影響の評価

### 正の影響
1. **認証システムの安定性向上**:
   - バリデーションエラーの根本解決
   - 型不整合による予期しない動作の排除

2. **業務要件への完全適合**:
   - 先頭ゼロ付き社員番号のサポート
   - 飲食店業界の慣習への対応

3. **開発効率の向上**:
   - 繰り返し可能な環境構築
   - 安定した初期データ投入

### 将来への影響
1. **Phase 2（API実装）への影響**:
   - 文字列型社員番号でのAPI仕様統一
   - Session-Cookie認証の実装基盤確立

2. **フロントエンド開発への影響**:
   - 社員番号入力フィールドの文字列処理
   - ゼロ埋め表示の自然な実装

3. **運用・保守への影響**:
   - 社員番号管理の明確化
   - データ移行時の型統一

---

## 今後の課題・検討事項

### 短期的課題（Phase 2）
1. **API仕様の統一**:
   - JSON APIでの社員番号文字列処理
   - CSRF トークン管理の実装

2. **エラーハンドリング**:
   - 認証失敗時の適切なレスポンス
   - バリデーションエラーの統一的な処理

### 中長期的検討事項
1. **セキュリティ強化**:
   - パスワード複雑度の要件検討
   - アカウントロック機能の必要性

2. **多店舗対応**:
   - 店舗別社員番号体系の検討
   - ロール権限の詳細化

3. **監査機能**:
   - ログイン履歴の記録
   - パスワード変更履歴の管理

---

## 関連ドキュメント
- [Phase1-実装履歴記録](../../logs/issue-02/Phase1-implementation-log.md)
- [employee_number バリデーション問題解決](../../troubleshooting/employee-number-validation/)
- [詳細設計書](../../../詳細設計.md)
- [Issue #2 タスク管理](../../../../issues/issue-02-authentication.md)

---

## 承認・レビュー
- **実装者**: GitHub Copilot
- **実装日**: 2025年7月4日
- **レビューステータス**: Phase 1 完了確認済み
- **次フェーズ**: Phase 2 認証API実装へ移行
