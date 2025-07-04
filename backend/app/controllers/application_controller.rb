class ApplicationController < ActionController::API
  # API共通設定
  before_action :set_default_response_format

  # ルートエンドポイント
  def index
    render json: {
      message: "Kitchen Shift Manager API",
      version: "1.0.0",
      environment: Rails.env,
      timestamp: Time.current.iso8601
    }, status: :ok
  end

  private

  def set_default_response_format
    request.format = :json
  end
end
