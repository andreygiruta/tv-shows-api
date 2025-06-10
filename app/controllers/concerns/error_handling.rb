module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ArgumentError, with: :handle_bad_request
    rescue_from Date::Error, with: :handle_date_error
  end

  private

  def handle_standard_error(exception)
    Rails.logger.error "StandardError: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    render json: {
      error: 'An unexpected error occurred',
      details: Rails.env.development? ? exception.message : nil
    }, status: :internal_server_error
  end

  def handle_not_found(exception)
    render json: {
      error: 'Resource not found',
      details: exception.message
    }, status: :not_found
  end

  def handle_bad_request(exception)
    render json: {
      error: exception.message
    }, status: :bad_request
  end

  def handle_date_error(exception)
    render json: {
      error: 'Invalid date format. Use YYYY-MM-DD',
      details: exception.message
    }, status: :bad_request
  end
end
