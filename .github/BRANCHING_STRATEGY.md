# ブランチ戦略

## 概要

このプロジェクトでは Git Flow を簡略化したブランチ戦略を採用しています。

## ブランチ構成

### 恒久ブランチ

#### `main`
- **用途**: 本番環境デプロイ用
- **保護**: プルリクエストのみマージ可能
- **デプロイ**: mainへのpushで自動的にRenderに本番デプロイ
- **タグ**: リリース時にバージョンタグを付与

#### `develop`
- **用途**: 開発統合ブランチ
- **役割**: 各機能ブランチの統合とテスト
- **マージ**: フィーチャーブランチからのPRを受け入れ

### 一時ブランチ

#### `feat/[issue-number]-[description]`
- **用途**: 新機能開発
- **例**: `feat/01-development-setup`, `feat/02-authentication`
- **派生元**: `develop`
- **マージ先**: `develop`

#### `fix/[issue-number]-[description]`
- **用途**: バグ修正
- **例**: `fix/01-login-error`, `fix/02-excel-export`
- **派生元**: `develop`
- **マージ先**: `develop`

#### `hotfix/[description]`
- **用途**: 本番環境の緊急修正
- **派生元**: `main`
- **マージ先**: `main` および `develop`

## ワークフロー

### 機能開発フロー

1. **ブランチ作成**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feat/[issue-number]-[description]
   ```

2. **開発作業**
   - コミットメッセージは Conventional Commits に従う
   - 定期的に develop からリベース

3. **プルリクエスト**
   - develop ブランチに向けて PR 作成
   - レビュー後にマージ

4. **クリーンアップ**
   ```bash
   git checkout develop
   git pull origin develop
   git branch -d feat/[issue-number]-[description]
   ```

### リリースフロー

1. **リリース準備**
   ```bash
   git checkout develop
   git pull origin develop
   # テスト・検証実施
   ```

2. **本番リリース**
   ```bash
   git checkout main
   git merge develop
   git tag v[version]
   git push origin main --tags
   ```

## コミットメッセージ規約

[Conventional Commits](https://www.conventionalcommits.org/) に従います：

- `feat:` 新機能
- `fix:` バグ修正  
- `docs:` ドキュメント更新
- `style:` コードフォーマット
- `refactor:` リファクタリング
- `test:` テスト追加・修正
- `chore:` その他の変更

### 例
```
feat: 打刻機能のAPI実装
fix: Excel出力時の時刻計算エラー修正
docs: READMEにデプロイ手順を追加
```

## Issue との対応

各ブランチは対応する Issue 番号を含めます：

- Issue #1 → `feat/01-development-setup`
- Issue #2 → `feat/02-authentication`  
- Issue #3 → `feat/03-timecard-system`
- Issue #4 → `feat/04-admin-features`
- Issue #5 → `feat/05-excel-export`
- Issue #6 → `feat/06-render-deploy`

## ブランチ保護設定

### main ブランチ
- Require pull request reviews before merging
- Require status checks to pass before merging
- Require branches to be up to date before merging
- Restrict pushes that create files

### develop ブランチ  
- Require pull request reviews before merging
- Require status checks to pass before merging
