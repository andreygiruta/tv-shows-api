require "sidekiq"
require "sidekiq-cron"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }

  # Schedule daily import job at 2 AM UTC
  Sidekiq::Cron::Job.load_from_hash({
    "daily_tvmaze_import" => {
      "cron" => "0 2 * * *",
      "class" => "DailyTvmazeImportJob",
      "args" => [ 90, "US" ]
    }
  })
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
end
