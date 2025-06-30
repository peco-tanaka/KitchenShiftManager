FROM node:20-alpine AS build-frontend
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend .
RUN npm run build

FROM ruby:3.4-alpine AS dev
RUN apk add --no-cache build-base postgresql-dev bash git
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]

FROM ruby:3.4-alpine AS prod
RUN apk add --no-cache postgresql-dev bash
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle config --global frozen 1 && \
    bundle install --without development test && \
    bundle clean --force
COPY . .
COPY --from=build-frontend /app/frontend/dist /app/public
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0", "-e", "production"]