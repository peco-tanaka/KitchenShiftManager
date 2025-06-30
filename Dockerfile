# ====================
# Frontend Build Stage
# ====================
FROM node:22.17.0-alpine AS build-frontend
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci --only=production
COPY frontend .
RUN npm run build

# ====================
# Development Stage
# ====================
FROM ruby:3.4.4 AS dev

# 開発用パッケージのインストール
RUN apt-get update -qq && apt-get install -y \
    postgresql-client \
    build-essential \
    libpq-dev \
    curl \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*

# アプリケーションディレクトリの作成
WORKDIR /app

# Gemfile と Gemfile.lock をコピー
COPY backend/Gemfile backend/Gemfile.lock ./

# Bundler のインストールと Gems のインストール
RUN gem install bundler:2.4.19
RUN bundle install

# アプリケーションコードをコピー
COPY backend .

# ポート 3000 を公開
EXPOSE 3000

# デフォルトコマンド
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# ====================
# Production Stage
# ====================
FROM ruby:3.4.4-alpine AS prod

# 本番用パッケージのインストール（最小限）
RUN apk add --no-cache \
    postgresql-client \
    build-base \
    postgresql-dev \
    tzdata \
    && rm -rf /var/cache/apk/*

# アプリケーションディレクトリの作成
WORKDIR /app

# Gemfile と Gemfile.lock をコピー
COPY backend/Gemfile backend/Gemfile.lock ./

# Bundler のインストールと本番用 Gems のインストール
RUN gem install bundler:2.4.19
RUN bundle config set --local deployment 'true' \
    && bundle config set --local without 'development test' \
    && bundle install

# アプリケーションコードをコピー
COPY backend .

# フロントエンドのビルド済みファイルをコピー
COPY --from=build-frontend /app/frontend/dist ./public

# Rails の秘密鍵とアセットのプリコンパイル用環境変数
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=1

# アセットのプリコンパイル（本番用）
RUN bundle exec rails assets:precompile

# 非 root ユーザーの作成
RUN addgroup -g 1001 -S rails && \
    adduser -S rails -u 1001 -G rails

# アプリケーションディレクトリの所有者変更
RUN chown -R rails:rails /app
USER rails

# ポート 3000 を公開
EXPOSE 3000

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# 本番用コマンド
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
