class EpisodeSerializer
  def initialize(episode)
    @episode = episode
  end

  def as_json
    {
      id: episode.id,
      name: episode.name,
      season: episode.season,
      episode_number: episode.episode_number,
      type: episode.episode_type,
      runtime: episode.runtime,
      rating: episode.rating,
      summary: episode.summary,
      image_medium: episode.image_medium,
      image_original: episode.image_original,
      airdate: release_date&.airdate,
      airtime: release_date&.airtime,
      show: ShowSerializer.new(episode.tv_show).as_json
    }
  end

  private

  attr_reader :episode

  def release_date
    @release_date ||= episode.release_dates.first
  end
end