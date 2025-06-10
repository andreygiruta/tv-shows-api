class DailyTvmazeImportJob
  include Sidekiq::Job

  sidekiq_options retry: 3, queue: 'default'

  def perform(days = 90, country = '')
    Rails.logger.info 'Starting daily TVMaze import job'

    start_time = Time.current
    import_service = TvmazeImportService.new

    begin
      result = import_service.import_upcoming_episodes(days: days, country: country)

      duration = Time.current - start_time
      Rails.logger.info "Daily import completed in #{duration.round(2)}s: #{result[:processed]} processed, #{result[:errors]} errors"

      result
    rescue StandardError => e
      Rails.logger.error "Daily import job failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise e
    end
  end
end
