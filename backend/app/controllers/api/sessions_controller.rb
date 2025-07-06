# frozen_string_literal: true

module Api
  class SessionsController < ApplicationController
    # CSRFトークンを利用しない認証方式の為、CSRF保護をスキップ（セッションCookie認証やトークン認証を利用）
    skip_before_action :verify_authenticity_token, only: [:create, :destroy, :show]

    # ログインエンドポイント
    # POST /api/login
    def create
      user = User.find_by(employee_number: login_params[:employee_number])

      if user&.valid_password?(login_params[:password])
        # Devise のsign_inヘルパーを使用してセッション開始
        sign_in(user)
        render json: {
          status: 'success',
          message: 'ログインしました',
          user: user_response(user)
        }, status: :ok
      else
        render json: {
          status: 'error',
          message: '社員番号またはパスワードが正しくありません'
        }, status: :unauthorized
      end
    end

    # ログアウトエンドポイント
    # POST /api/logout
    def destroy
      if user_signed_in?
        # Devise のsign_outヘルパーを使用してセッション終了
        sign_out(current_user)
        render json: {
          status: 'success',
          message: 'ログアウトしました'
        }, status: :ok
      else
        render json: {
          status: 'error',
          message: 'ログインしていません'
        }, status: :unauthorized
      end
    end

    # 現在ユーザー取得エンドポイント
    # GET /api/me
    def show
      if user_signed_in?
        render json: {
          status: 'success',
          user: user_response(current_user)
        }, status: :ok
      else
        render json: {
          status: 'error',
          message: '認証が必要です'
        }, status: :unauthorized
      end
    end

    private

    def login_params
      params.require(:user).permit(:employee_number, :password)
    end

    # ユーザー情報のレスポンス形式を統一
    def user_response(user)
      {
        id: user.id,
        employee_number: user.employee_number,
        last_name: user.last_name,
        first_name: user.first_name,
        role: user.role,
        hourly_wage: user.hourly_wage,
        hired_on: user.hired_on&.iso8601,
        terminated_on: user.terminated_on&.iso8601
      }
    end
  end
end
