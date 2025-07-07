class ApplicationController < ActionController::API
  # Deviseの機能を有効化（Session-Cookie認証用）
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  # CSRF保護を有効化（APIでは基本的に無効にするが、Deviseとの統合のため）
  protect_from_forgery with: :null_session

  # API共通設定
  before_action :set_default_response_format

  # ルートエンドポイント
  def index
    render json: {
      status: "success",
      message: "飲食店勤怠管理システム API",
      version: "1.0.0",
      environment: Rails.env,
      timestamp: Time.current.iso8601
    }, status: :ok
  end

  protected

  # 認証が必要なエンドポイント用のbefore_action
  def authenticate_user!
    unless user_signed_in?
      render json: {
        status: "error",
        message: "認証が必要です。ログインしてください。"
      }, status: :unauthorized
    end
  end

  # 管理者権限が必要なエンドポイント用のbefore_action
  def ensure_manager!
    authenticate_user!
    unless current_user&.manager?
      render json: {
        status: "error",
        message: "管理者権限が必要です。"
      }, status: :forbidden
    end
  end

  private

  def set_default_response_format
    request.format = :json
  end
end
