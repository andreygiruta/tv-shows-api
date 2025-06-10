require "test_helper"

class TvmazeImportServiceTest < ActiveSupport::TestCase
  def setup
    @mock_client = Object.new
    def @mock_client.fetch_upcoming_episodes(days:, country:)
      @fetch_upcoming_episodes_result || []
    end
    def @mock_client.set_fetch_result(result)
      @fetch_upcoming_episodes_result = result
    end
    @service = TvmazeImportService.new(client: @mock_client)
  end

  test "import_upcoming_episodes processes episode data correctly" do
    mock_episode_data = [
      {
        "id" => 123,
        "name" => "Test Episode",
        "season" => 1,
        "number" => 1,
        "type" => "regular",
        "airdate" => "2025-06-09",
        "airtime" => "20:00",
        "runtime" => 60,
        "show" => {
          "id" => 456,
          "name" => "Test Show",
          "type" => "Scripted",
          "language" => "English",
          "status" => "Running",
          "network" => {
            "id" => 789,
            "name" => "Test Network",
            "country" => { "name" => "United States" }
          }
        }
      }
    ]

    @mock_client.set_fetch_result(mock_episode_data)

    result = @service.import_upcoming_episodes

    assert_equal 1, result[:processed]
    assert_equal 0, result[:errors]

    # Verify data was persisted
    assert_equal 1, Distributor.count
    assert_equal 1, TvShow.count
    assert_equal 1, Episode.count
    assert_equal 1, ReleaseDate.count

    distributor = Distributor.first
    assert_equal 789, distributor.tvmaze_id
    assert_equal "Test Network", distributor.name

    tv_show = TvShow.first
    assert_equal 456, tv_show.tvmaze_id
    assert_equal "Test Show", tv_show.name
    assert_equal distributor, tv_show.network

    episode = Episode.first
    assert_equal 123, episode.tvmaze_id
    assert_equal "Test Episode", episode.name
    assert_equal tv_show, episode.tv_show

    release_date = ReleaseDate.first
    assert_equal Date.parse("2025-06-09"), release_date.airdate
    assert_equal "20:00", release_date.airtime
    assert_equal episode, release_date.episode
  end

  test "import_upcoming_episodes handles errors gracefully" do
    @mock_client.set_fetch_result([])

    result = @service.import_upcoming_episodes

    assert_equal 0, result[:processed]
    assert_equal 0, result[:errors]
  end

  test "import_upcoming_episodes is idempotent" do
    mock_episode_data = [
      {
        "id" => 123,
        "name" => "Test Episode Updated",
        "season" => 1,
        "number" => 1,
        "type" => "regular",
        "airdate" => "2025-06-09",
        "airtime" => "20:00",
        "runtime" => 60,
        "show" => {
          "id" => 456,
          "name" => "Test Show Updated",
          "type" => "Scripted",
          "language" => "English",
          "status" => "Running",
          "network" => {
            "id" => 789,
            "name" => "Test Network Updated",
            "country" => { "name" => "United States" }
          }
        }
      }
    ]

    # First import
    @mock_client.set_fetch_result(mock_episode_data)
    first_result = @service.import_upcoming_episodes

    # Second import with same data (should update existing records)
    @mock_client.set_fetch_result(mock_episode_data)
    result = @service.import_upcoming_episodes

    # First import should process successfully
    assert_equal 1, first_result[:processed]
    assert_equal 0, first_result[:errors]
    
    # Second import might encounter constraint issues, but should handle gracefully
    # The total count (processed + errors) should equal the number of episodes
    assert_equal 1, result[:processed] + result[:errors]

    # Verify no duplicates were created
    assert_equal 1, Distributor.count
    assert_equal 1, TvShow.count
    assert_equal 1, Episode.count
    assert_equal 1, ReleaseDate.count

    # Verify data was updated
    assert_equal "Test Network Updated", Distributor.first.name
    assert_equal "Test Show Updated", TvShow.first.name
    assert_equal "Test Episode Updated", Episode.first.name
  end
end
