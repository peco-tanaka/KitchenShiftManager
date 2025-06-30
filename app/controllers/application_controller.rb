class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_error
  
  def health
    render json: { status: 'ok', timestamp: Time.current }
  end
  
  def fallback_index_html
    render file: 'public/index.html'
  end
  
  private
  
  def handle_error(exception)
    Rails.logger.error "#{exception.class}: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    render json: { 
      error: exception.message,
      status: 'error' 
    }, status: :internal_server_error
  end
end