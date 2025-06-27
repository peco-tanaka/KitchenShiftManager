# Issue #1: 開発基盤セットアップ

## 概要
Git リポジトリ初期化、Docker-Compose（dev & prod）、VS Code 推奨設定などの開発環境を構築し、Rails API + Vite React のローカル開発環境を整備する。

## ゴール
`docker compose up` で Rails API ＋ Vite React がローカル起動し、「Hello」画面が確認できる状態を実現する。

## スコープ

### 含まれる内容
- [ ] Git リポジトリの設定とブランチ戦略
- [ ] Docker環境の構築（開発・本番両対応）
- [ ] Rails 7.2 API-only アプリケーションの作成
- [ ] Vite + React 19 フロントエンドアプリケーションの作成
- [ ] PostgreSQL 16 データベース環境
- [ ] VS Code 推奨設定とワークスペース設定
- [ ] 基本的な Hello World 画面の実装

### 含まれない内容
- 認証機能の実装
- データベーススキーマ設計
- 本格的なUI/UXデザイン

## 受入条件

- [ ] `docker compose up` でローカル環境が起動する
- [ ] Rails API が http://localhost:3000 で応答する
- [ ] React アプリが http://localhost:5173 で応答する
- [ ] PostgreSQL が正常に接続される
- [ ] フロントエンドからAPIへのHTTPリクエストが成功する
- [ ] 「Hello World」的な画面が表示される
- [ ] VS Code での開発環境が整っている

## 技術仕様

### バックエンド
- Ruby 3.4.4
- Rails 7.2.2.1 (API-only mode)
- PostgreSQL 16

### フロントエンド
- React 19.1.0
- TypeScript 5.5.2
- Vite 6.0.0

### インフラ
- Docker & Docker Compose
- Multi-stage Dockerfile

## タスク

### Git & プロジェクト初期化
- [x] .gitignore の適切な設定
- [x] README.md の作成
- [x] ブランチ保護設定

### Docker環境構築
- [ ] docker-compose.dev.yml の作成
- [ ] docker-compose.prod.yml の作成
- [ ] Multi-stage Dockerfile の作成
- [ ] PostgreSQL コンテナ設定

### Rails API セットアップ
- [ ] Rails new でAPI-onlyアプリ作成
- [ ] Gemfile の設定（必要な gem の追加）
- [ ] データベース設定
- [ ] CORS設定
- [ ] 基本的なヘルスチェックエンドポイント

### React フロントエンド セットアップ
- [ ] Vite + React + TypeScript 環境構築
- [ ] 必要なパッケージのインストール
- [ ] 基本的なルーティング設定
- [ ] API通信のセットアップ
- [ ] Hello World コンポーネント

### VS Code設定
- [ ] .vscode/settings.json
- [ ] .vscode/extensions.json
- [ ] デバッグ設定

### 動作確認
- [ ] ローカル環境でのエンドツーエンド動作確認
- [ ] API疎通確認
- [ ] Hot reload 動作確認

## 参考資料
- `/doc/詳細設計.md` の「システムアーキテクチャ概要」
- `/doc/詳細設計.md` の「コンテナ & デプロイ構成」
- `/doc/詳細設計.md` の「主要技術スタック」
