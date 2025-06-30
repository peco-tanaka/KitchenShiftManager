# Kitchen Shift Manager - Issue Review System

## 概要

勤怠管理システムの開発過程における課題（issue）の確認とレビューを行う機能を実装しました。

## 機能

### Issue管理
- 開発課題の作成・閲覧・更新・削除
- ステータス管理（Open, In Progress, Under Review, Resolved, Closed）
- 優先度設定（Low, Medium, High, Critical）
- 課題タイプ（Development, Bug, Feature, Improvement, Task）

### Review機能
- 課題に対するレビューコメントの追加
- レビューステータス（Approved, Rejected, Needs Changes, Pending）
- レビュアー名と評価の記録
- レビュー結果に基づく課題ステータスの自動更新

## 技術構成

### バックエンド
- Rails 7.2 API-only mode
- PostgreSQL 16
- RESTful API設計

### フロントエンド  
- React 19.0
- TypeScript 5.2
- Vite 6.0
- TailwindCSS 3.3
- React Query for state management

### インフラ
- Docker & Docker Compose
- Multi-stage build

## セットアップ

### 開発環境

```bash
# リポジトリクローン
git clone <repository-url>
cd KitchenShiftManager

# Docker環境での起動
docker-compose -f docker-compose.dev.yml up --build

# フロントエンド: http://localhost:5173
# バックエンドAPI: http://localhost:3000
```

### API使用例

```bash
# Issue一覧取得
GET /api/issues

# Issue詳細取得  
GET /api/issues/1

# Review作成
POST /api/issues/1/reviews
{
  "review": {
    "comment": "レビューコメント",
    "status": "approved", 
    "reviewer_name": "レビュアー名"
  }
}
```

## 画面構成

1. **Issue一覧画面** (`/`)
   - 全Issue表示
   - ステータス・優先度フィルター
   - 新規Issue作成リンク

2. **Issue詳細画面** (`/issues/:id`)
   - Issue詳細情報表示
   - 関連レビュー表示
   - 新規レビュー作成フォーム

3. **Issue作成画面** (`/create`)
   - 新規Issue作成フォーム

## Issue #1準拠の実装

本実装は詳細設計書の Issue #1「開発基盤セットアップ」の内容に従い、以下を実現しています：

- ✅ Docker-Compose による開発環境
- ✅ Rails API + Vite React のローカル開発環境  
- ✅ PostgreSQL データベース環境
- ✅ 基本的なHello World画面（Issue管理画面として実装）
- ✅ CORS設定とAPI疎通確認

さらに、勤怠管理システムの開発プロセスを支援するIssueレビュー機能を追加実装しました。
