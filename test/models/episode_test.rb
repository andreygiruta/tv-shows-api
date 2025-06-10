require "test_helper"

class EpisodeTest < ActiveSupport::TestCase
  def setup
    @distributor = Distributor.create!(
      tvmaze_id: 1,
      name: "Test Network"
    )

    @tv_show = TvShow.create!(
      tvmaze_id: 1,
      name: "Test Show",
      network: @distributor
    )

    @episode = Episode.new(
      tvmaze_id: 1,
      name: "Test Episode",
      season: 1,
      episode_number: 1,
      episode_type: "regular",
      runtime: 60,
      rating: 8.0,
      tv_show: @tv_show
    )
  end

  test "should be valid with valid attributes" do
    assert @episode.valid?
  end

  test "should require name" do
    @episode.name = nil
    assert_not @episode.valid?
    assert_includes @episode.errors[:name], "can't be blank"
  end

  test "should require tvmaze_id" do
    @episode.tvmaze_id = nil
    assert_not @episode.valid?
    assert_includes @episode.errors[:tvmaze_id], "can't be blank"
  end

  test "should require season and episode_number" do
    @episode.season = nil
    @episode.episode_number = nil
    assert_not @episode.valid?
    assert_includes @episode.errors[:season], "can't be blank"
    assert_includes @episode.errors[:episode_number], "can't be blank"
  end

  test "should require unique tvmaze_id" do
    @episode.save!

    duplicate = Episode.new(
      tvmaze_id: 1,
      name: "Another Episode",
      season: 2,
      episode_number: 1,
      tv_show: @tv_show
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:tvmaze_id], "has already been taken"
  end

  test "should require unique season and episode_number per show" do
    @episode.save!

    duplicate = Episode.new(
      tvmaze_id: 2,
      name: "Another Episode",
      season: 1,
      episode_number: 1,
      tv_show: @tv_show
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:season], "has already been taken"
  end

  test "should belong to tv_show" do
    @episode.save!
    assert_equal @tv_show, @episode.tv_show
  end

  test "should have many release_dates" do
    @episode.save!

    release_date = ReleaseDate.create!(
      airdate: Date.current,
      episode: @episode
    )

    assert_includes @episode.release_dates, release_date
  end

  test "by_season scope should filter by season" do
    @episode.save!

    season2_episode = Episode.create!(
      tvmaze_id: 200,
      name: "Season 2 Episode",
      season: 2,
      episode_number: 5,
      tv_show: @tv_show
    )

    season1_episodes = Episode.by_season(1)
    assert_includes season1_episodes, @episode
    assert_not_includes season1_episodes, season2_episode
  end

  test "find_or_create_by_tvmaze_data should create new episode" do
    episode_data = {
      "id" => 123,
      "name" => "New Episode",
      "season" => 2,
      "number" => 5,
      "type" => "finale",
      "runtime" => 90,
      "rating" => { "average" => 9.0 },
      "image" => {
        "medium" => "https://example.com/episode_medium.jpg",
        "original" => "https://example.com/episode_original.jpg"
      },
      "summary" => "<p>Episode summary</p>"
    }

    assert_difference "Episode.count", 1 do
      episode = Episode.find_or_create_by_tvmaze_data(episode_data, @tv_show)

      assert_equal 123, episode.tvmaze_id
      assert_equal "New Episode", episode.name
      assert_equal 2, episode.season
      assert_equal 5, episode.episode_number
      assert_equal "finale", episode.episode_type
      assert_equal 90, episode.runtime
      assert_equal 9.0, episode.rating
      assert_equal "https://example.com/episode_medium.jpg", episode.image_medium
      assert_equal "https://example.com/episode_original.jpg", episode.image_original
      assert_equal "<p>Episode summary</p>", episode.summary
      assert_equal @tv_show, episode.tv_show
    end
  end

  test "find_or_create_by_tvmaze_data should handle nil values" do
    episode_data = {
      "id" => 124,
      "name" => "Minimal Episode",
      "season" => 3,
      "number" => 1,
      "rating" => { "average" => nil },
      "image" => nil
    }

    episode = Episode.find_or_create_by_tvmaze_data(episode_data, @tv_show)

    assert_equal 124, episode.tvmaze_id
    assert_equal "Minimal Episode", episode.name
    assert_nil episode.rating
    assert_nil episode.image_medium
    assert_nil episode.image_original
  end
end
