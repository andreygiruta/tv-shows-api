class DateUtilityService
  class << self
    def parse_date(date_string)
      return nil unless date_string.present?

      Date.parse(date_string)
    rescue Date::Error => e
      Rails.logger.error "Invalid date format: #{date_string} - #{e.message}"
      nil
    end

    def parse_date!(date_string)
      return nil unless date_string.present?

      Date.parse(date_string)
    rescue Date::Error => e
      Rails.logger.error "Invalid date format: #{date_string} - #{e.message}"
      raise ArgumentError, "Invalid date format: #{date_string}"
    end

    def safe_date_range(date_from, date_to)
      parsed_from = parse_date!(date_from)
      parsed_to = parse_date!(date_to)

      raise ArgumentError, 'Start date cannot be after end date' if parsed_from && parsed_to && parsed_from > parsed_to

      [parsed_from, parsed_to]
    end

    def format_date(date, format = '%Y-%m-%d')
      return nil unless date

      date.strftime(format)
    rescue StandardError => e
      Rails.logger.error "Error formatting date: #{date} - #{e.message}"
      nil
    end
  end
end
