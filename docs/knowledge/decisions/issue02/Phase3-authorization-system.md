# Phase 3: 認可システム - 設計判断と変更履歴

## 概要
Phase 3では、Punditを使用した認可システムを実装し、manager/employeeの権限制御を確立しました。

## 主要な設計判断

### 1. Pundit認可ライブラリの採用
**判断**: Punditをメイン認可システムとして採用
**理由**:
- Rails標準的なアプローチで保守性が高い
- ポリシーベースの明確な権限分離
- テストが容易で可読性が高い

### 2. 権限設計の厳格化
**判断**: employeeには打刻機能（create）のみを許可し、参照・更新権限は一切与えない
**理由**:
- 要件定義での「employeeは打刻のみ」を厳密に実装
- セキュリティを最優先し、最小権限の原則を適用
- 管理者による一元管理を徹底

### 3. ApplicationController基盤の活用
**判断**: 認証・認可メソッドをApplicationControllerに集約し、継承で共有
**理由**:
- DRY原則の徹底
- 一箇所での変更が全体に反映される保守性
- 既存実装の有効活用

### 4. ポリシークラスの構造化
**判断**: 以下の3つのポリシークラスを作成
- `ApplicationPolicy`: 基底クラス（全てmanager専用）
- `UserPolicy`: ユーザー管理（manager専用）
- `TimeCardPolicy`: 打刻データ（manager全権限、employee作成のみ）
- `AdminPolicy`: 管理機能（manager専用）

**理由**:
- 責任の明確な分離
- 将来の拡張に対応可能な構造
- 権限マトリックスの明確化

## 実装された権限マトリックス

| リソース | アクション | manager | employee |
|----------|-----------|---------|----------|
| User     | index     | ✅      | ❌       |
| User     | show      | ✅      | ❌       |
| User     | create    | ✅      | ❌       |
| User     | update    | ✅      | ❌       |
| User     | destroy   | ✅      | ❌       |
| TimeCard | index     | ✅      | ❌       |
| TimeCard | show      | ✅      | ❌       |
| TimeCard | create    | ✅      | ✅       |
| TimeCard | update    | ✅      | ❌       |
| TimeCard | destroy   | ✅      | ❌       |
| Admin    | 全機能    | ✅      | ❌       |

## 技術的変更点

### ApplicationController
- `include Pundit::Authorization`の追加
- `rescue_from Pundit::NotAuthorizedError`の実装
- `handle_unauthorized`メソッドの追加

### ポリシーファイル
- `app/policies/application_policy.rb`: Punditジェネレーターで生成後カスタマイズ
- `app/policies/user_policy.rb`: 新規作成
- `app/policies/time_card_policy.rb`: 新規作成  
- `app/policies/admin_policy.rb`: 新規作成

### エラーハンドリング
- 統一されたJSONエラーレスポンス形式
- 認証失敗: 401 Unauthorized
- 認可失敗: 403 Forbidden

## 次のPhaseへの引き継ぎ事項

### Phase 4: フロントエンド認証で必要な対応
1. 認証状態管理（AuthContext）
2. 権限ベースのUI制御
3. 認可エラーハンドリング
4. ルート保護機能

### 将来の拡張ポイント
1. 細かい権限制御（フィールドレベル）
2. 時間ベースの権限制御
3. 部門別権限管理
4. 監査ログ機能

## 検証済み動作
- Railsコンソールでの権限テスト実行済み
- manager/employeeの権限分離確認済み
- Punditエラーハンドリング動作確認済み
