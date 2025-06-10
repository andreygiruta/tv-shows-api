require "net/http"
require "json"

class TvmazeClient
  BASE_URL = "https://api.tvmaze.com".freeze
  USER_AGENT = "TV-Shows-API/1.0".freeze
  RATE_LIMIT_DELAY = 0.5 # 0.5 seconds between requests to respect rate limits

  class ApiError < StandardError; end
  class RateLimitError < StandardError; end

  def initialize
    @last_request_time = Time.current
  end

  def fetch_schedule(country: "US", date: nil)
    params = { country: country }
    params[:date] = date.strftime("%Y-%m-%d") if date

    get_request("/schedule", params)
  end

  def fetch_schedule_range(start_date, end_date, country: "US")
    episodes = []
    current_date = start_date

    while current_date <= end_date
      begin
        daily_schedule = fetch_schedule(country: country, date: current_date)
        episodes.concat(daily_schedule) if daily_schedule
        current_date += 1.day
        sleep(RATE_LIMIT_DELAY)
      rescue RateLimitError => e
        Rails.logger.warn "Rate limit hit, waiting longer: #{e.message}"
        sleep(10)
        retry
      rescue ApiError => e
        Rails.logger.error "API error for #{current_date}: #{e.message}"
        current_date += 1.day
      end
    end

    episodes
  end

  def fetch_upcoming_episodes(days: 90, country: "US")
    start_date = Date.current
    end_date = start_date + days.days

    fetch_schedule_range(start_date, end_date, country: country)
  end

  private

  def get_request(endpoint, params = {})
    respect_rate_limit

    uri = URI("#{BASE_URL}#{endpoint}")
    uri.query = URI.encode_www_form(params) unless params.empty?

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = USER_AGENT

    response = http.request(request)

    case response.code.to_i
    when 200
      JSON.parse(response.body)
    when 429
      raise RateLimitError, "Rate limit exceeded"
    when 404
      Rails.logger.warn "Not found: #{uri}"
      nil
    else
      raise ApiError, "HTTP #{response.code}: #{response.body}"
    end
  rescue JSON::ParserError => e
    raise ApiError, "Invalid JSON response: #{e.message}"
  rescue RateLimitError
    raise
  rescue StandardError => e
    raise ApiError, "Request failed: #{e.message}"
  end

  def respect_rate_limit
    time_since_last_request = Time.current - @last_request_time
    if time_since_last_request < RATE_LIMIT_DELAY
      sleep(RATE_LIMIT_DELAY - time_since_last_request)
    end
    @last_request_time = Time.current
  end
end
