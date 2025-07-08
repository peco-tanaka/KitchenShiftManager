# Phase 3: 認可システム - 実装履歴とTips

## 実装の流れ

### 3.1 Pundit設定
1. **Pundit初期化**: `rails generate pundit:install`実行済み（Phase 1で完了）
2. **ApplicationPolicy**: 生成されたファイルをプロジェクト要件に合わせてカスタマイズ
3. **ApplicationController**: Pundit組み込みとエラーハンドリング実装

### 3.2 ポリシー作成
1. **UserPolicy**: manager専用の厳格な権限設計
2. **TimeCardPolicy**: employeeには作成のみ許可
3. **AdminPolicy**: 管理機能全般の権限制御

### 3.3 コントローラー保護
1. **ApplicationController基盤**: 既存実装の確認と活用
2. **継承による機能共有**: 個別コントローラーでの実装不要を確認

## 技術的Tips

### Punditテストの実行方法
```ruby
# Railsコンソールでのポリシーテスト
manager = User.find_by(role: 'manager')
employee = User.find_by(role: 'employee')

# 権限チェック例
UserPolicy.new(manager, User).index?   # => true
UserPolicy.new(employee, User).index?  # => false

# TimeCardモデル未作成時のテスト
TimeCardPolicy.new(manager, nil).create?   # => true
TimeCardPolicy.new(employee, nil).create?  # => true
```

### Punditの基本パターン
```ruby
# コントローラーでの使用例
def index
  authorize User  # クラスレベルの認可
  @users = policy_scope(User)  # スコープによるフィルタリング
end

def show
  authorize @user  # インスタンスレベルの認可
end
```

### エラーハンドリングパターン
```ruby
# ApplicationControllerでの統一エラーハンドリング
rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized

private

def handle_unauthorized
  render json: {
    status: "error",
    message: "この操作を実行する権限がありません。"
  }, status: :forbidden
end
```

## 障害対応履歴

### 問題1: TimeCardモデル未作成時のテストエラー
**症状**: `NameError: uninitialized constant TimeCard`
**原因**: Punditポリシーテスト時にモデルクラスが必要
**解決**: テスト用に`nil`を渡してポリシーメソッドを検証

### 問題2: セッションコントローラーの認証要件
**症状**: `Api::SessionsController`に`before_action`が必要か判断が必要
**解決**: 認証処理の性質上、各メソッドで個別に認証チェックを実装済みのため不要と判断

## パフォーマンス考慮

### Punditの最適化
- `policy_scope`使用時のN+1クエリ注意
- 複雑な権限チェックでのデータベース負荷考慮
- キャッシュ戦略の検討（将来実装）

## セキュリティ考慮

### 最小権限の原則
- employeeには打刻機能のみ許可
- デフォルトで全権限拒否、明示的許可のみ有効
- 管理者権限の厳格なチェック

### 認可チェックの徹底
- 全APIエンドポイントでの認可実装
- フロントエンドでの補完的権限チェック
- 認可ログの記録（将来実装予定）

## 次のPhaseで活用予定の機能

### AuthContext（フロントエンド）
- 現在ユーザーの権限情報管理
- APIレスポンスでの権限情報受け渡し
- UI表示制御での権限判定

### ProtectedRoute
- React Routerでのルート保護
- 権限ベースのページアクセス制御
- リダイレクト処理の実装

## 学習ポイント

### Punditの設計思想
- ポリシーベースの明確な権限分離
- 単一責任の原則に基づく設計
- テスト駆動開発での権限検証

### Railsの継承活用
- ApplicationControllerでの共通機能実装
- 子コントローラーでの機能継承
- DRY原則の実践
