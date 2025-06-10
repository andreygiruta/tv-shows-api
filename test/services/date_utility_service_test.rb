require "test_helper"

class DateUtilityServiceTest < ActiveSupport::TestCase
  test "parse_date returns nil for empty string" do
    assert_nil DateUtilityService.parse_date("")
    assert_nil DateUtilityService.parse_date(nil)
  end

  test "parse_date returns parsed date for valid string" do
    date = DateUtilityService.parse_date("2025-06-09")
    assert_equal Date.new(2025, 6, 9), date
  end

  test "parse_date returns nil for invalid date string" do
    assert_nil DateUtilityService.parse_date("invalid-date")
    assert_nil DateUtilityService.parse_date("2025-13-45")
  end

  test "parse_date! raises error for invalid date string" do
    assert_raises(ArgumentError) do
      DateUtilityService.parse_date!("invalid-date")
    end
  end

  test "parse_date! returns parsed date for valid string" do
    date = DateUtilityService.parse_date!("2025-06-09")
    assert_equal Date.new(2025, 6, 9), date
  end

  test "safe_date_range returns parsed dates for valid range" do
    date_from, date_to = DateUtilityService.safe_date_range("2025-06-09", "2025-06-16")
    assert_equal Date.new(2025, 6, 9), date_from
    assert_equal Date.new(2025, 6, 16), date_to
  end

  test "safe_date_range raises error when start date is after end date" do
    assert_raises(ArgumentError, "Start date cannot be after end date") do
      DateUtilityService.safe_date_range("2025-06-16", "2025-06-09")
    end
  end

  test "format_date returns formatted string for valid date" do
    date = Date.new(2025, 6, 9)
    assert_equal "2025-06-09", DateUtilityService.format_date(date)
    assert_equal "09/06/2025", DateUtilityService.format_date(date, '%d/%m/%Y')
  end

  test "format_date returns nil for nil input" do
    assert_nil DateUtilityService.format_date(nil)
  end
end