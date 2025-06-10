require 'test_helper'

class TvShowTest < ActiveSupport::TestCase
  def setup
    @distributor = Distributor.create!(
      tvmaze_id: 1,
      name: 'Test Network',
      country: 'United States'
    )

    @tv_show = TvShow.new(
      tvmaze_id: 1,
      name: 'Test Show',
      show_type: 'Scripted',
      language: 'English',
      status: 'Running',
      rating: 8.5,
      network: @distributor
    )
  end

  test 'should be valid with valid attributes' do
    assert @tv_show.valid?
  end

  test 'should require name' do
    @tv_show.name = nil
    assert_not @tv_show.valid?
    assert_includes @tv_show.errors[:name], "can't be blank"
  end

  test 'should require tvmaze_id' do
    @tv_show.tvmaze_id = nil
    assert_not @tv_show.valid?
    assert_includes @tv_show.errors[:tvmaze_id], "can't be blank"
  end

  test 'should require unique tvmaze_id' do
    @tv_show.save!

    duplicate = TvShow.new(
      tvmaze_id: 1,
      name: 'Another Show'
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:tvmaze_id], 'has already been taken'
  end

  test 'should belong to network' do
    @tv_show.save!
    assert_equal @distributor, @tv_show.network
  end

  test 'should have many episodes' do
    @tv_show.save!

    episode = Episode.create!(
      tvmaze_id: 1,
      name: 'Test Episode',
      season: 1,
      episode_number: 1,
      tv_show: @tv_show
    )

    assert_includes @tv_show.episodes, episode
  end

  test 'by_status scope should filter by status' do
    @tv_show.save!

    ended_show = TvShow.create!(
      tvmaze_id: 2,
      name: 'Ended Show',
      status: 'Ended',
      network: @distributor
    )

    running_shows = TvShow.by_status('Running')
    assert_includes running_shows, @tv_show
    assert_not_includes running_shows, ended_show
  end

  test 'by_rating scope should filter by minimum rating' do
    @tv_show.save!

    low_rated_show = TvShow.create!(
      tvmaze_id: 2,
      name: 'Low Rated Show',
      rating: 5.0,
      network: @distributor
    )

    high_rated_shows = TvShow.by_rating(8.0)
    assert_includes high_rated_shows, @tv_show
    assert_not_includes high_rated_shows, low_rated_show
  end

  test 'find_or_create_by_tvmaze_data should create new show' do
    show_data = {
      'id' => 123,
      'name' => 'New Show',
      'type' => 'Documentary',
      'language' => 'Spanish',
      'status' => 'In Development',
      'runtime' => 30,
      'premiered' => '2025-01-01',
      'ended' => '2025-12-31',
      'officialSite' => 'https://example.com',
      'rating' => { 'average' => 7.5 },
      'genres' => %w[Drama Comedy],
      'schedule' => {
        'time' => '20:00',
        'days' => %w[Monday Tuesday]
      },
      'image' => {
        'medium' => 'https://example.com/medium.jpg',
        'original' => 'https://example.com/original.jpg'
      },
      'summary' => '<p>Test summary</p>'
    }

    assert_difference 'TvShow.count', 1 do
      tv_show = TvShow.find_or_create_by_tvmaze_data(show_data, @distributor)

      assert_equal 123, tv_show.tvmaze_id
      assert_equal 'New Show', tv_show.name
      assert_equal 'Documentary', tv_show.show_type
      assert_equal 'Spanish', tv_show.language
      assert_equal 'In Development', tv_show.status
      assert_equal 30, tv_show.runtime
      assert_equal Date.parse('2025-01-01'), tv_show.premiered
      assert_equal Date.parse('2025-12-31'), tv_show.ended
      assert_equal 'https://example.com', tv_show.official_site
      assert_equal 7.5, tv_show.rating
      assert_equal 'Drama, Comedy', tv_show.genres
      assert_equal '20:00', tv_show.schedule_time
      assert_equal 'Monday, Tuesday', tv_show.schedule_days
      assert_equal 'https://example.com/medium.jpg', tv_show.image_medium
      assert_equal 'https://example.com/original.jpg', tv_show.image_original
      assert_equal '<p>Test summary</p>', tv_show.summary
      assert_equal @distributor, tv_show.network
    end
  end

  test 'find_or_create_by_tvmaze_data should handle nil values gracefully' do
    show_data = {
      'id' => 124,
      'name' => 'Minimal Show',
      'premiered' => nil,
      'ended' => nil,
      'rating' => { 'average' => nil },
      'genres' => nil,
      'schedule' => nil,
      'image' => nil
    }

    tv_show = TvShow.find_or_create_by_tvmaze_data(show_data)

    assert_equal 124, tv_show.tvmaze_id
    assert_equal 'Minimal Show', tv_show.name
    assert_nil tv_show.premiered
    assert_nil tv_show.ended
    assert_nil tv_show.rating
    assert_nil tv_show.genres
    assert_nil tv_show.schedule_time
    assert_nil tv_show.schedule_days
    assert_nil tv_show.image_medium
  end
end
