require 'test_helper'
require 'webmock/minitest'

class TvmazeClientTest < ActiveSupport::TestCase
  def setup
    @client = TvmazeClient.new
    WebMock.enable!
  end

  def teardown
    WebMock.disable!
  end

  test 'fetch_schedule returns parsed JSON for valid response' do
    mock_response = [
      {
        'id' => 1,
        'name' => 'Test Episode',
        'airdate' => '2025-06-09',
        'show' => { 'id' => 1, 'name' => 'Test Show' }
      }
    ]

    stub_request(:get, 'https://api.tvmaze.com/schedule')
      .with(query: { country: 'US' })
      .to_return(status: 200, body: mock_response.to_json)

    result = @client.fetch_schedule(country: 'US')
    assert_equal mock_response, result
  end

  test 'fetch_schedule handles 404 gracefully' do
    stub_request(:get, 'https://api.tvmaze.com/schedule')
      .with(query: { country: '' })
      .to_return(status: 404)

    result = @client.fetch_schedule
    assert_nil result
  end

  test 'fetch_schedule raises RateLimitError on 429' do
    stub_request(:get, 'https://api.tvmaze.com/schedule')
      .with(query: { country: '' })
      .to_return(status: 429)

    assert_raises(TvmazeClient::RateLimitError) do
      @client.fetch_schedule
    end
  end

  test 'fetch_schedule raises ApiError on other HTTP errors' do
    stub_request(:get, 'https://api.tvmaze.com/schedule')
      .with(query: { country: '' })
      .to_return(status: 500)

    assert_raises(TvmazeClient::ApiError) do
      @client.fetch_schedule
    end
  end

  test 'fetch_upcoming_episodes fetches range of dates' do
    stub_request(:get, %r{https://api\.tvmaze\.com/schedule})
      .to_return(status: 200, body: [].to_json)

    result = @client.fetch_upcoming_episodes(days: 2)
    assert_instance_of Array, result
  end
end
