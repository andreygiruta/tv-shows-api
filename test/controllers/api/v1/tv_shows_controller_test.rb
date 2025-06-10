require "test_helper"

class Api::V1::TvShowsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @distributor = Distributor.create!(
      tvmaze_id: 1,
      name: "Test Network",
      country: "United States"
    )

    @tv_show = TvShow.create!(
      tvmaze_id: 1,
      name: "Test Show",
      show_type: "Scripted",
      language: "English",
      status: "Running",
      rating: 8.5,
      genres: "Drama, Comedy",
      network: @distributor
    )

    @episode = Episode.create!(
      tvmaze_id: 1,
      name: "Test Episode",
      season: 1,
      episode_number: 1,
      episode_type: "regular",
      runtime: 60,
      rating: 8.0,
      tv_show: @tv_show
    )

    @release_date = ReleaseDate.create!(
      airdate: Date.current + 1.day,
      airtime: "20:00",
      episode: @episode
    )
  end

  test "index returns episodes within date range" do
    date_from = Date.current
    date_to = Date.current + 7.days

    get "/api/v1/tvshows", params: {
      date_from: date_from.strftime("%Y-%m-%d"),
      date_to: date_to.strftime("%Y-%m-%d")
    }

    assert_response :success
    json_response = JSON.parse(response.body)

    assert_equal 1, json_response["data"].length
    episode_data = json_response["data"].first

    assert_equal @episode.name, episode_data["name"]
    assert_equal @tv_show.name, episode_data["show"]["name"]
    assert_equal @distributor.name, episode_data["show"]["network"]["name"]
  end

  test "index requires date_from and date_to parameters" do
    get "/api/v1/tvshows"

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_includes json_response["error"], "date_from and date_to parameters are required"
  end

  test "index filters by distributor" do
    date_from = Date.current
    date_to = Date.current + 7.days

    get "/api/v1/tvshows", params: {
      date_from: date_from.strftime("%Y-%m-%d"),
      date_to: date_to.strftime("%Y-%m-%d"),
      distributor: "Test Network"
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response["data"].length

    get "/api/v1/tvshows", params: {
      date_from: date_from.strftime("%Y-%m-%d"),
      date_to: date_to.strftime("%Y-%m-%d"),
      distributor: "Non-existent Network"
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 0, json_response["data"].length
  end

  test "index filters by country" do
    date_from = Date.current
    date_to = Date.current + 7.days

    get "/api/v1/tvshows", params: {
      date_from: date_from.strftime("%Y-%m-%d"),
      date_to: date_to.strftime("%Y-%m-%d"),
      country: "United States"
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response["data"].length
  end

  test "index filters by rating" do
    date_from = Date.current
    date_to = Date.current + 7.days

    get "/api/v1/tvshows", params: {
      date_from: date_from.strftime("%Y-%m-%d"),
      date_to: date_to.strftime("%Y-%m-%d"),
      rating: "8.0"
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response["data"].length

    get "/api/v1/tvshows", params: {
      date_from: date_from.strftime("%Y-%m-%d"),
      date_to: date_to.strftime("%Y-%m-%d"),
      rating: "9.0"
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 0, json_response["data"].length
  end

  test "index includes pagination metadata" do
    date_from = Date.current
    date_to = Date.current + 7.days

    get "/api/v1/tvshows", params: {
      date_from: date_from.strftime("%Y-%m-%d"),
      date_to: date_to.strftime("%Y-%m-%d"),
      page: 1,
      per_page: 5
    }

    assert_response :success
    json_response = JSON.parse(response.body)

    assert_includes json_response, "pagination"
    pagination = json_response["pagination"]
    assert_includes pagination, "current_page"
    assert_includes pagination, "total_pages"
    assert_includes pagination, "total_count"
    assert_includes pagination, "per_page"
  end

  test "index sets appropriate cache headers" do
    date_from = Date.current
    date_to = Date.current + 7.days

    get "/api/v1/tvshows", params: {
      date_from: date_from.strftime("%Y-%m-%d"),
      date_to: date_to.strftime("%Y-%m-%d")
    }

    assert_response :success
    assert_includes response.headers["Cache-Control"], "public"
    assert_includes response.headers["Cache-Control"], "max-age=3600"
    assert_includes response.headers["Vary"], "Accept"
  end

  test "index handles invalid date format" do
    get "/api/v1/tvshows", params: {
      date_from: "invalid-date",
      date_to: "2025-06-09"
    }

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_includes json_response["error"], "Invalid date format"
  end
end
