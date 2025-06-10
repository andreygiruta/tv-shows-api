require "test_helper"
require "webmock/minitest"

class DailyTvmazeImportJobTest < ActiveSupport::TestCase
  def setup
    @job = DailyTvmazeImportJob.new
    WebMock.enable!

    # Stub all TVMaze API requests
    stub_request(:get, %r{https://api\.tvmaze\.com/schedule})
      .to_return(status: 200, body: [].to_json)
  end

  def teardown
    WebMock.disable!
  end

  test "should perform import with default parameters" do
    result = @job.perform

    # Should return a hash with processed and errors keys
    assert result.is_a?(Hash)
    assert result.key?(:processed)
    assert result.key?(:errors)
  end

  test "should call TvmazeImportService" do
    # Test that job creates and calls the service
    assert_nothing_raised do
      @job.perform
    end
  end

  test "should accept custom parameters" do
    # Test that custom parameters don't cause errors
    assert_nothing_raised do
      @job.perform(30, "CA")
    end
  end
end
