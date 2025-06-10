class Episode < ApplicationRecord
  belongs_to :tv_show
  has_many :release_dates, dependent: :destroy

  validates :name, presence: true
  validates :tvmaze_id, presence: true, uniqueness: true
  validates :season, :episode_number, presence: true
  validates :season, :episode_number, uniqueness: { scope: :tv_show_id }

  scope :by_season, ->(season) { where(season: season) }
  scope :airing_between, lambda { |start_date, end_date|
    joins(:release_dates).where(release_dates: { airdate: start_date..end_date })
  }

  def self.find_or_create_by_tvmaze_data(episode_data, tv_show)
    find_or_create_by(tvmaze_id: episode_data['id']) do |episode|
      episode.name = episode_data['name']
      episode.season = episode_data['season']
      episode.episode_number = episode_data['number']
      episode.episode_type = episode_data['type']
      episode.runtime = episode_data['runtime']
      episode.rating = episode_data.dig('rating', 'average')
      episode.image_medium = episode_data.dig('image', 'medium')
      episode.image_original = episode_data.dig('image', 'original')
      episode.summary = episode_data['summary']
      episode.tv_show = tv_show
    end
  end
end
