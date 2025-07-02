# GitHub Copilot カスタムインストラクション

## 重要な指示
**タスクに取り組む時、コーディング前に必ず`実装の概要`・`技術的解説`を開発者に説明してください。学習に繋げる目的のためです**
**コーディング作業はこまめに分割し、段階的に進めてください。**
**コーディングについては、1つのコーディングタスクが完了した時点で解説を必ず行なってください**
**コード生成・提案の前に必ず `/doc/詳細設計.md` ファイルを確認し、そこに記載された技術仕様・アーキテクチャ・実装方針に従ってください。詳細設計が最優先の参考資料です。**
**破壊的な変更を伴う場合には必ず確認をとってください。**
**`/doc/詳細設計.md` ファイルの内容から変更を加える必要がある場合には、必ず確認をとってください。**
##ターミナルのコマンドは、一度に実行するのではなく、段階的に細分化して実行します。
  - コマンド例：
    - 細分化前: `docker run --rm -v "$(pwd)/backend:/app" -w /app ruby:3.4.4 bash -c "gem install rails -v 7.2.2 && rails new . --api --database=postgresql --skip-git --skip-bundle"`
    - 細分化後:
      1. `docker run --rm -v "$(pwd)/backend:/app" -w /app ruby:3.4.4 bash"
      2. `gem install rails -v 7.2.2`
      3. `rails new . --api --database=postgresql --skip-git --skip-bundle`

## プロジェクト概要
飲食店勤怠管理システム - 小規模飲食店の出退勤管理とシフト管理を行うWebアプリケーション

## 開発ガイドライン
**`/issues`ディレクトリ内の各issueにそってステップバイステップで実装を進めてください。**
**`/issues`ディレクトリ内の各issueファイルのタスクについて、完了したらチェックを入れてください。**
**`/issues`のタスクが進んだら、適切な粒度で/doc/knowledge/内のドキュメントを更新してください。**
    - `decisions/` `logs`: それぞれ一つのissueに対して1フォルダずつ用意し、更新内容を記述したファイルを作成・更新
    - 粒度: まとまったタスクが終了した時点
    - `decisions/`フォルダの内容: 主要な設計判断 & 変更履歴
    - `logs/`フォルダの内容: 実装履歴 & 障害対応履歴 & Tips
**/doc/knowledge/内の更新をする場合には必ず確認をとってください**
**/doc/knowledge/内の Markdown ファイルを必ずインデックスし、**
    - decisions/ を詳細設計.md と同格に扱う
    - logs/ も参照し、関連する Tips があれば提案に活かす
    - 新しい設計判断や障害対応を行った場合は、該当フォルダへの追記を促すこと
**/doc/knowledge/内のファイル名テンプレートは以下です
    - decisions/issue01/1-issue-title.md
    - decisions/issue01/completion-summary.md
    - logs/issue01/1-issue-title.md
    - logs/issue01/overall-flow.md

## 技術スタック
- **言語**: Ruby 3.4.4
- **バックエンド**: Ruby on Rails 7.2.2 (API-only モード)
- **フロントエンド**: React 19.1.0 + TypeScript 5.5.2
- **ビルドツール**: Vite 6.0.0
- **データベース**: PostgreSQL 16.x
- **認証**: Devise 4.9.4 (Session-Cookie認証)
- **認可**: Pundit 2.3
- **Excel生成**: Axlsx 4.1
- **状態管理**: @tanstack/react-query 5.81.2
- **ルーティング**: react-router-dom 7.3.0
- **UI/CSS**: Tailwind CSS 4.1 + @headlessui/react 2.2
- **テスト**: RSpec-Rails 7.2 + FactoryBot-Rails 7.5
- **Linter**: RuboCop 1.63
- **デプロイ**: Render (Docker)
- **開発環境**: Docker Compose

## コーディング規約

### Ruby/Rails
- Ruby 3.4.4を使用
- Rails 7.2.2標準のコーディング規約に従う
- RuboCop 1.63の設定に準拠
- APIモードでの開発
- Serializers（ActiveModel::Serializer）を使用
- Strong Parametersを適切に使用
- 適切なバリデーションとエラーハンドリング

### React/TypeScript
- React 19.1.0 + TypeScript 5.5.2 strictモードを有効化
- 関数コンポーネントとHooksを優先
- Props型定義を必須とする
- ESLint/Prettierの設定に従う
- コンポーネントは単一責任の原則
- カスタムHooksでロジックを分離
- Vite 6.0.0でのビルド設定

### データベース
- マイグレーションファイルは適切にバージョン管理
- 外部キー制約を適切に設定
- インデックスの適切な設定
- NOT NULL制約の適切な使用

## アーキテクチャパターン

### バックエンド
- RESTful API設計
- Controller → Service → Model の責任分離
- Serializerでレスポンス形式を統一
- 適切な HTTP ステータスコードの使用

### フロントエンド
- コンポーネント設計：Atomic Design を参考
- 状態管理：@tanstack/react-query 5.81.2 + React Hook + Context API
- API通信：Fetch API + カスタムHooks
- ルーティング：react-router-dom 7.3.0
- UI/CSS：Tailwind CSS 4.1 + @headlessui/react 2.2
- フォーム：react-hook-form 8.1.0
- アイコン：lucide-react 0.372

## セキュリティ要件
- 認証：Devise 4.9.4 (Session-Cookie認証)
- 認可：Pundit 2.3
- CORS設定の適切な管理
- CSRF保護
- SQLインジェクション対策
- XSS対策

## 命名規約
- **ファイル名**: snake_case (Ruby), kebab-case (React)
- **クラス名**: PascalCase
- **メソッド名**: snake_case (Ruby), camelCase (TypeScript)
- **変数名**: snake_case (Ruby), camelCase (TypeScript)
- **定数名**: SCREAMING_SNAKE_CASE

## コメント・ドキュメント
- 複雑なロジックには適切なコメント
- APIエンドポイントにはOpenAPI/Swagger形式のコメント
- README.mdの継続的な更新
- 変更履歴の適切な記録

## コミットメッセージ方針
- `type: 日本語名` 形式でコミットメッセージを記述
- `type` は以下のいずれかを使用:
  - `feat`: 新機能追加
  - `fix`: バグ修正
  - `docs`: ドキュメント変更
  - `style`: フォーマット修正（コードの動作に影響しない）
  - `refactor`: リファクタリング（機能変更なし）
  - `test`: テストコードの追加・修正
  - `chore`: その他の変更（ビルドツールやライブラリの更新など）
  - `issue`: Issueに関連する変更
- コミットは小さく、1つの機能や修正に対して1つのコミットを心がける

## ブランチ戦略
- main: 本番環境デプロイ用（保護ブランチ）
- develop: 開発統合ブランチ
- feat/*: 機能開発ブランチ
- fix/*: バグ修正ブランチ
- hotfix/*: 緊急修正ブランチ

## テスト方針
- **バックエンド**: RSpec-Rails 7.2（Model, Request, Service）
- **フロントエンド**: Jest + React Testing Library
- FactoryBot-Rails 7.5でテストデータ生成
- テスト可能な設計を心がける
- 重要なビジネスロジックには必ずテストを作成

## エラーハンドリング
- ユーザーフレンドリーなエラーメッセージ
- 適切なログ出力
- フロントエンドでの適切なエラー表示
- バックエンドでの例外処理

## パフォーマンス考慮事項
- N+1クエリの回避
- 適切なページネーション
- フロントエンドでの適切なメモ化
- 画像最適化

## デプロイ・運用
- Docker環境での動作確認
- 環境変数での設定管理
- ログの適切な出力レベル設定
- Renderでの本番環境最適化

## 開発フロー
1. **必須**: `/doc/詳細設計.md` の内容を確認・理解
2. 機能要件の確認
3. 設計ドキュメントの確認
4. 適切なブランチでの開発
5. テストの作成・実行
6. コードレビュー準備
7. デプロイ前の動作確認

## 実装ガイドライン
- **詳細設計書の遵守**: 全ての実装は `/doc/詳細設計.md` に記載された仕様に基づいて行う
- **バージョン整合性**: 技術スタックのバージョンは詳細設計書に記載されたものを厳格に使用
- **アーキテクチャ準拠**: DB設計、API仕様、フロントエンド構成は詳細設計書に従う
- **命名規約の統一**: 詳細設計書で定義されたテーブル名、カラム名、API エンドポイント名を使用

## 注意事項
- 個人情報の適切な取り扱い
- セキュリティを常に意識した実装
- 可読性・保守性を重視したコード作成
- チーム開発を意識した分かりやすい実装

## 参考ドキュメント
- **最重要**: `/doc/詳細設計.md` - 技術仕様・アーキテクチャ・実装方針（必読）
- `/doc/要件定義.md` - システム要件
- `/doc/ER図.md` - データベース設計
- `/issues/` - 開発タスク管理

## 設計書参照のルール
1. **コード作成前**: 必ず詳細設計書の関連セクションを確認
2. **技術選択時**: 詳細設計書記載の技術スタック・バージョンを優先
3. **API設計時**: 詳細設計書のAPI仕様（OpenAPI草案）に準拠
4. **DB操作時**: 詳細設計書のテーブル設計・関連定義に従う
5. **疑問発生時**: 詳細設計書の該当箇所を再確認し、記載内容を最優先
