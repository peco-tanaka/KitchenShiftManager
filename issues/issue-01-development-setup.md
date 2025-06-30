# Issue #1: 開発基盤セットアップ

## 概要
Git リポジトリ初期化、Docker-Compose（dev & prod）、VS Code 推奨設定などの開発環境を構築し、Rails API + Vite React のローカル開発環境を整備する。

## ゴール
`docker compose up` で Rails API ＋ Vite React がローカル起動し、「Hello」画面が確認できる状態を実現する。

## スコープ

### 含まれる内容
- [x] Git リポジトリの設定とブランチ戦略
- [x] Docker環境の構築（開発・本番両対応）
- [x] Rails 7.2 API-only アプリケーションの作成
- [x] Vite + React 19 フロントエンドアプリケーションの作成
- [x] PostgreSQL 16 データベース環境
- [x] 基本的な Hello World 画面の実装

### 含まれない内容
- 認証機能の実装
- データベーススキーマ設計
- 本格的なUI/UXデザイン

## 受入条件

- [x] `docker compose up` でローカル環境が起動する
- [x] Rails API が http://localhost:3000 で応答する
- [x] React アプリが http://localhost:5173 で応答する
- [x] PostgreSQL が正常に接続される
- [x] フロントエンドからAPIへのHTTPリクエストが成功する
- [x] 「Hello World」的な画面が表示される

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

### 1.Git & プロジェクト初期化
- [x] .gitignore の適切な設定
- [x] README.md の作成
- [x] ブランチ保護設定

### 2.Docker環境構築
- [x] docker-compose.dev.yml の作成
- [x] docker-compose.prod.yml の作成
- [x] Multi-stage Dockerfile の作成
- [x] PostgreSQL コンテナ設定

### 3.Rails API セットアップ
- [x] Rails new でAPI-onlyアプリ作成
- [x] Gemfile の設定（必要な gem の追加）
- [x] データベース設定
- [x] CORS設定
- [x] 基本的なヘルスチェックエンドポイント
- [x] Railsサーバー接続確認

### 4.React フロントエンド セットアップ
- [x] Vite + React + TypeScript 環境構築
- [x] 必要なパッケージのインストール
- [x] 基本的なルーティング設定
- [x] API通信のセットアップ
- [x] Hello World コンポーネント

### 5.動作確認
- [x] ローカル環境でのエンドツーエンド動作確認
- [x] API疎通確認
- [x] Hot reload 動作確認

## 参考資料
- `/doc/詳細設計.md` の「システムアーキテクチャ概要」
- `/doc/詳細設計.md` の「コンテナ & デプロイ構成」
- `/doc/詳細設計.md` の「主要技術スタック」
