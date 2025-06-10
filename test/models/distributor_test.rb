require "test_helper"

class DistributorTest < ActiveSupport::TestCase
  def setup
    @distributor = Distributor.new(
      tvmaze_id: 1,
      name: "Test Network",
      country: "United States"
    )
  end

  test "should be valid with valid attributes" do
    assert @distributor.valid?
  end

  test "should require name" do
    @distributor.name = nil
    assert_not @distributor.valid?
    assert_includes @distributor.errors[:name], "can't be blank"
  end

  test "should require tvmaze_id" do
    @distributor.tvmaze_id = nil
    assert_not @distributor.valid?
    assert_includes @distributor.errors[:tvmaze_id], "can't be blank"
  end

  test "should require unique tvmaze_id" do
    @distributor.save!

    duplicate = Distributor.new(
      tvmaze_id: 1,
      name: "Another Network"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:tvmaze_id], "has already been taken"
  end

  test "should have many tv_shows" do
    @distributor.save!

    tv_show = TvShow.create!(
      tvmaze_id: 1,
      name: "Test Show",
      network: @distributor
    )

    assert_includes @distributor.tv_shows, tv_show
  end

  test "by_country scope should filter by country" do
    @distributor.save!

    canada_distributor = Distributor.create!(
      tvmaze_id: 2,
      name: "Canadian Network",
      country: "Canada"
    )

    us_distributors = Distributor.by_country("United States")
    assert_includes us_distributors, @distributor
    assert_not_includes us_distributors, canada_distributor
  end

  test "find_or_create_by_tvmaze_data should create new distributor" do
    network_data = {
      "id" => 123,
      "name" => "New Network",
      "country" => { "name" => "United Kingdom" },
      "officialSite" => "https://example.com"
    }

    assert_difference "Distributor.count", 1 do
      distributor = Distributor.find_or_create_by_tvmaze_data(network_data)

      assert_equal 123, distributor.tvmaze_id
      assert_equal "New Network", distributor.name
      assert_equal "United Kingdom", distributor.country
      assert_equal "https://example.com", distributor.official_site
    end
  end

  test "find_or_create_by_tvmaze_data should find existing distributor" do
    @distributor.save!

    network_data = {
      "id" => 1,
      "name" => "Updated Network Name",
      "country" => { "name" => "Canada" }
    }

    assert_no_difference "Distributor.count" do
      distributor = Distributor.find_or_create_by_tvmaze_data(network_data)
      assert_equal @distributor, distributor
    end
  end

  test "find_or_create_by_tvmaze_data should return nil for nil data" do
    result = Distributor.find_or_create_by_tvmaze_data(nil)
    assert_nil result
  end
end
