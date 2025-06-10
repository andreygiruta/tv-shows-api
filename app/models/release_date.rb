class ReleaseDate < ApplicationRecord
  belongs_to :episode

  validates :airdate, presence: true
  validates :airdate, uniqueness: { scope: :episode_id }

  scope :upcoming, -> { where("airdate >= ?", Date.current) }
  scope :between_dates, ->(start_date, end_date) { where(airdate: start_date..end_date) }
  scope :today, -> { where(airdate: Date.current) }

  def self.find_or_create_by_episode_data(episode_data, episode)
    return nil unless episode_data["airdate"]

    airdate = DateUtilityService.parse_date(episode_data["airdate"])
    return nil unless airdate

    find_or_create_by(episode: episode, airdate: airdate) do |release_date|
      release_date.airtime = episode_data["airtime"]
    end
  end
end
