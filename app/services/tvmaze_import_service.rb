class TvmazeImportService
  def initialize(client: TvmazeClient.new)
    @client = client
    @logger = Rails.logger
  end

  def import_upcoming_episodes(days: 90, country: "")
    @logger.info "Starting import of upcoming episodes for #{days} days"

    episodes_data = @client.fetch_upcoming_episodes(days: days, country: country)
    processed_count = 0
    error_count = 0

    episodes_data.each do |episode_data|
      begin
        import_episode_data(episode_data)
        processed_count += 1
      rescue StandardError => e
        error_count += 1
        @logger.error "Failed to process episode #{episode_data['id']}: #{e.message}"
      end
    end

    @logger.info "Import completed: #{processed_count} processed, #{error_count} errors"
    { processed: processed_count, errors: error_count }
  end

  private

  def import_episode_data(episode_data)
    return unless episode_data["show"] && episode_data["airdate"]

    ActiveRecord::Base.transaction do
      # Create or update network/distributor
      network = create_or_update_distributor(episode_data["show"]["network"])

      # Create or update TV show
      tv_show = create_or_update_tv_show(episode_data["show"], network)

      # Create or update episode
      episode = create_or_update_episode(episode_data, tv_show)

      # Create or update release date
      create_or_update_release_date(episode_data, episode)
    end
  end

  def create_or_update_distributor(network_data)
    return nil unless network_data

    distributor = Distributor.find_by(tvmaze_id: network_data["id"])

    if distributor
      # Update existing distributor
      distributor.update!(
        name: network_data["name"],
        country: network_data.dig("country", "name"),
        official_site: network_data["officialSite"]
      )
    else
      # Create new distributor
      distributor = Distributor.create!(
        tvmaze_id: network_data["id"],
        name: network_data["name"],
        country: network_data.dig("country", "name"),
        official_site: network_data["officialSite"]
      )
    end

    distributor
  end

  def create_or_update_tv_show(show_data, network)
    tv_show = TvShow.find_by(tvmaze_id: show_data["id"])
    show_attributes = show_attributes(network, show_data)

    if tv_show
      tv_show.update!(show_attributes.remove(:name))
    else
      tv_show = TvShow.create!(show_attributes.merge(tvmaze_id: show_data["id"]))
    end

    tv_show
  end

  def create_or_update_episode(episode_data, tv_show)
    episode = Episode.find_by(tvmaze_id: episode_data["id"])

    episode_attributes = episode_attributes(episode_data, tv_show)

    if episode
      episode.update!(episode_attributes.remove(:name))
    else
      episode = Episode.create!(episode_attributes.merge(tvmaze_id: episode_data["id"]))
    end

    episode
  end

  def create_or_update_release_date(episode_data, episode)
    return unless episode_data["airdate"]

    airdate = DateUtilityService.parse_date(episode_data["airdate"])
    release_date = ReleaseDate.find_by(episode: episode, airdate: airdate)

    if release_date
      release_date.update!(airtime: episode_data["airtime"])
    else
      ReleaseDate.create!(
        episode: episode,
        airdate: airdate,
        airtime: episode_data["airtime"]
      )
    end
  end


  def episode_attributes(episode_data, tv_show)
    {
      name:           episode_data["name"],
      season:         episode_data["season"],
      episode_number: episode_data["number"],
      episode_type:   episode_data["type"],
      runtime:        episode_data["runtime"],
      rating:         episode_data.dig("rating", "average"),
      image_medium:   episode_data.dig("image", "medium"),
      image_original: episode_data.dig("image", "original"),
      summary:        episode_data["summary"],
      tv_show:        tv_show
    }
  end

  def show_attributes(network, show_data)
    {
      name:           show_data["name"],
      show_type:      show_data["type"],
      language:       show_data["language"],
      status:         show_data["status"],
      runtime:        show_data["runtime"],
      premiered:      DateUtilityService.parse_date(show_data["premiered"]),
      ended:          DateUtilityService.parse_date(show_data["ended"]),
      official_site:   show_data["officialSite"],
      rating:         show_data.dig("rating", "average"),
      genres:         show_data["genres"]&.join(", "),
      schedule_time:  show_data.dig("schedule", "time"),
      schedule_days:  show_data.dig("schedule", "days")&.join(", "),
      image_medium:   show_data.dig("image", "medium"),
      image_original: show_data.dig("image", "original"),
      summary:        show_data["summary"],
      network:        network
    }
  end
end
