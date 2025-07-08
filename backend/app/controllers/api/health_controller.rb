class Api::HealthController < ApplicationController
  # ヘルスチェックエンドポイント
  # GET /api/health

  before_action :authenticate_user!, only: [:index]
  before_action :ensure_manager!, only: [:index] # 管理者権限が必要なエンドポイント

  def index
    database_status = check_database_connection

    render json: {
      status: database_status[:connected] ? "healthy" : "unhealthy",
      service: "Kitchen Shift Manager API",
      version: "1.0.0",
      environment: Rails.env,
      timestamp: Time.current.iso8601,
      database: database_status,
      uptime: uptime_info
    }, status: database_status[:connected] ? :ok : :service_unavailable
  end

  private

  def check_database_connection
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      {
        connected: true,
        adapter: ActiveRecord::Base.connection.adapter_name,
        database: ActiveRecord::Base.connection.current_database
      }
    rescue => e
      {
        connected: false,
        error: e.message
      }
    end
  end

  def uptime_info
    {
      process_started: $PROCESS_START_TIME ||= Time.current,
      uptime_seconds: Time.current - ($PROCESS_START_TIME ||= Time.current)
    }
  end
end
