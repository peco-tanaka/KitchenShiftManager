# Kitchen Shift Manager

勤怠管理システム（飲食店向け打刻・勤怠管理）

## 概要

従業員約40名の飲食店向けの勤怠管理システムです。従来のタイムカード＋Excel管理を置き換え、打刻から勤怠集計、Excel出力までを一元化します。

## 主な機能

- **打刻機能**: 出勤・退勤・外出・戻りの4種類の打刻
- **勤怠集計**: 15分切り捨て、時間帯別（昼・夜・深夜）実働時間計算
- **管理機能**: 従業員管理、手当管理、打刻修正
- **Excel出力**: 既存給与計算Excelテンプレートへの自動転記
- **権限制御**: 管理者（店長）と一般従業員の役割分離

## 技術スタック

### バックエンド
- Ruby 3.4.4
- Rails 7.2.2 (API-only)
- PostgreSQL 16
- Devise (認証)
- Pundit (認可)
- Axlsx (Excel生成)

### フロントエンド  
- React 19.1.0
- TypeScript 5.5.2
- Vite 6.0.0
- TailwindCSS 4.1
- React Query
- React Hook Form

### インフラ
- Docker & Docker Compose
- Render (本番環境)

## 開発計画

本プロジェクトは以下の6つのIssueで段階的に開発します：

### Issue #1: 開発基盤セットアップ
**ゴール**: `docker compose up` で Rails API ＋ Vite React がローカル起動し、「Hello」画面が確認できる

- Git リポジトリ設定
- Docker 環境構築（dev & prod）
- Rails API-only アプリケーション作成
- Vite + React フロントエンド作成
- PostgreSQL 設定
- VS Code 開発環境設定

### Issue #2: 認証・ロール制御
**ゴール**: manager だけ `/admin/*` へアクセス可、employee は打刻 API のみ利用可

- Devise による社員番号＋パスワード認証
- Session-Cookie 認証
- Pundit による権限制御
- ログイン・ログアウト画面

### Issue #3: 打刻 & 勤怠集計
**ゴール**: 出退勤ボタン → API → DB 保存 ➜ `/api/attendance?month=` が昼・夜・深夜別実働分を返す

- 打刻API（IN/OUT/BREAK）実装
- 15分切り捨てロジック
- 時間帯区分別集計
- 打刻画面UI
- 勤怠閲覧画面

### Issue #4: 管理機能（従業員・手当）
**ゴール**: manager が従業員情報・手当を追加／更新でき、打刻側に即反映

- 従業員CRUD API + UI
- 手当CRUD API + UI  
- 打刻データ手修正機能
- 管理画面UI

### Issue #5: Excel 出力連携
**ゴール**: `勤怠_YYYYMM.xlsx` がダウンロードでき、昼／夜／深夜の実働が正しいセルに入る

- Axlsx による Excel 生成
- ブロック配置アルゴリズム
- 時間帯別実働時間転記
- ダウンロード機能

### Issue #6: Render へデプロイ
**ゴール**: main ブランチへ push すると Render で本番環境が再デプロイされ、外部 URL でアプリが動作

- Docker イメージ最適化
- Render サービス作成
- Auto-Deploy 設定
- 本番環境動作確認

## 開発環境セットアップ

### 1. リポジトリのクローン
```bash
git clone <repository-url>
cd KitchenShiftManager
```

### 2. 環境変数ファイルの設定

環境変数ファイルのテンプレートから実際の設定ファイルを作成します：

#### 開発環境
```bash
cp .env.development.template .env.development
```

#### テスト環境（必要に応じて）
```bash
cp .env.test.template .env.test
```

#### 本番環境（Render等でのデプロイ時）
`.env.production.template` を参考に、プラットフォームの環境変数設定で値を指定してください。

### 3. 環境変数ファイルの説明

| ファイル | 用途 | Git管理 |
|---|---|---|
| `.env.development.template` | 開発環境のテンプレート | ✅ 管理対象 |
| `.env.test.template` | テスト環境のテンプレート | ✅ 管理対象 |
| `.env.production.template` | 本番環境のテンプレート | ✅ 管理対象 |
| `.env.development` | 開発環境の実際の設定 | ❌ 除外 |
| `.env.test` | テスト環境の実際の設定 | ❌ 除外 |

### 4. Docker Compose での起動
```bash
# 開発環境での起動
docker compose -f docker-compose.dev.yml up -d

# データベースの作成・マイグレーション
docker compose -f docker-compose.dev.yml exec backend rails db:create db:migrate
```

## データベース設定について

このプロジェクトでは、セキュリティと環境の柔軟性を保つため、データベース設定を環境変数で管理しています。

- `backend/config/database.yml` は環境変数参照のテンプレートとしてGit管理されています
- 実際の接続情報は `.env.*` ファイルで管理
- 各環境（開発・テスト・本番）で異なる設定を適用可能

### データベース接続に使用する環境変数

| 環境変数名 | 説明 | デフォルト値 |
|---|---|---|
| `DATABASE_HOST` | データベースホスト | localhost |
| `DATABASE_NAME` | データベース名 | attendance_dev |
| `DATABASE_USERNAME` | ユーザー名 | dev |
| `DATABASE_PASSWORD` | パスワード | devpass |
| `DATABASE_PORT` | ポート番号 | 5432 |
| `DATABASE_URL` | 接続URL（まとめて指定する場合） | - |

## 設計ドキュメント

- [要件定義](./doc/要件定義.md)
- [詳細設計](./doc/詳細設計.md)
- [ER図](./doc/ER図.md)

## Issue 詳細

各Issueの詳細なタスクリストと受入条件は以下を参照：

- [Issue #1: 開発基盤セットアップ](./issues/issue-01-development-setup.md)
- [Issue #2: 認証・ロール制御](./issues/issue-02-authentication.md)
- [Issue #3: 打刻 & 勤怠集計](./issues/issue-03-timecard-system.md)
- [Issue #4: 管理機能（従業員・手当）](./issues/issue-04-admin-features.md)
- [Issue #5: Excel 出力連携](./issues/issue-05-excel-export.md)
- [Issue #6: Render へデプロイ](./issues/issue-06-render-deploy.md)

## 開発の進め方

1. 各IssueのMarkdownファイルを確認し、タスクリストを把握
2. Issue番号順に順次開発を進める
3. 各Issueの受入条件をすべて満たしてから次に進む
4. 適宜コミット・プッシュし、進捗を記録
