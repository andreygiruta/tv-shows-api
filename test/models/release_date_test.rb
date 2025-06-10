require 'test_helper'

class ReleaseDateTest < ActiveSupport::TestCase
  def setup
    @distributor = Distributor.create!(
      tvmaze_id: 1,
      name: 'Test Network'
    )

    @tv_show = TvShow.create!(
      tvmaze_id: 1,
      name: 'Test Show',
      network: @distributor
    )

    @episode = Episode.create!(
      tvmaze_id: 1,
      name: 'Test Episode',
      season: 1,
      episode_number: 1,
      tv_show: @tv_show
    )

    @release_date = ReleaseDate.new(
      airdate: Date.current + 1.day,
      airtime: '20:00',
      episode: @episode
    )
  end

  test 'should be valid with valid attributes' do
    assert @release_date.valid?
  end

  test 'should require airdate' do
    @release_date.airdate = nil
    assert_not @release_date.valid?
    assert_includes @release_date.errors[:airdate], "can't be blank"
  end

  test 'should require unique airdate per episode' do
    @release_date.save!

    duplicate = ReleaseDate.new(
      airdate: @release_date.airdate,
      airtime: '21:00',
      episode: @episode
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:airdate], 'has already been taken'
  end

  test 'should belong to episode' do
    @release_date.save!
    assert_equal @episode, @release_date.episode
  end

  test 'upcoming scope should include future dates' do
    @release_date.save!

    past_release = ReleaseDate.create!(
      airdate: Date.current - 1.day,
      episode: @episode
    )

    upcoming_releases = ReleaseDate.upcoming
    assert_includes upcoming_releases, @release_date
    assert_not_includes upcoming_releases, past_release
  end

  test 'between_dates scope should filter by date range' do
    @release_date.save!

    future_episode = Episode.create!(
      tvmaze_id: 200,
      name: 'Future Episode',
      season: 2,
      episode_number: 5,
      tv_show: @tv_show
    )

    far_future_release = ReleaseDate.create!(
      airdate: Date.current + 30.days,
      episode: future_episode
    )

    start_date = Date.current
    end_date = Date.current + 7.days

    releases_in_range = ReleaseDate.between_dates(start_date, end_date)
    assert_includes releases_in_range, @release_date
    assert_not_includes releases_in_range, far_future_release
  end

  test "today scope should include today's releases" do
    today_episode = Episode.create!(
      tvmaze_id: 300,
      name: 'Today Episode',
      season: 3,
      episode_number: 10,
      tv_show: @tv_show
    )

    today_release = ReleaseDate.create!(
      airdate: Date.current,
      episode: today_episode
    )

    @release_date.save!

    today_releases = ReleaseDate.today
    assert_includes today_releases, today_release
    assert_not_includes today_releases, @release_date
  end

  test 'find_or_create_by_episode_data should create new release date' do
    episode_data = {
      'airdate' => '2025-06-15',
      'airtime' => '21:30'
    }

    assert_difference 'ReleaseDate.count', 1 do
      release_date = ReleaseDate.find_or_create_by_episode_data(episode_data, @episode)

      assert_equal Date.parse('2025-06-15'), release_date.airdate
      assert_equal '21:30', release_date.airtime
      assert_equal @episode, release_date.episode
    end
  end

  test 'find_or_create_by_episode_data should find existing release date' do
    @release_date.update!(airdate: Date.parse('2025-06-15'))

    episode_data = {
      'airdate' => '2025-06-15',
      'airtime' => '22:00'
    }

    assert_no_difference 'ReleaseDate.count' do
      release_date = ReleaseDate.find_or_create_by_episode_data(episode_data, @episode)

      assert_equal @release_date, release_date
      # The method finds existing record, doesn't update airtime
      assert_equal '20:00', release_date.airtime
    end
  end

  test 'find_or_create_by_episode_data should return nil without airdate' do
    episode_data = {
      'airtime' => '20:00'
    }

    result = ReleaseDate.find_or_create_by_episode_data(episode_data, @episode)
    assert_nil result
  end
end
