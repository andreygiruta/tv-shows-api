class TvShow < ApplicationRecord
  belongs_to :network, class_name: 'Distributor', optional: true
  has_many :episodes, dependent: :destroy
  has_many :release_dates, through: :episodes

  validates :name, presence: true
  validates :tvmaze_id, presence: true, uniqueness: true

  scope :by_status, ->(status) { where(status: status) }
  scope :by_rating, ->(min_rating) { where('rating >= ?', min_rating) }
  scope :premiering_between, ->(start_date, end_date) { where(premiered: start_date..end_date) }
  scope :with_upcoming_episodes, -> { joins(:release_dates).where('release_dates.airdate >= ?', Date.current).distinct }

  def self.find_or_create_by_tvmaze_data(show_data, network = nil)
    find_or_create_by(tvmaze_id: show_data['id']) do |show|
      show.name = show_data['name']
      show.show_type = show_data['type']
      show.language = show_data['language']
      show.status = show_data['status']
      show.runtime = show_data['runtime']
      show.premiered = DateUtilityService.parse_date(show_data['premiered'])
      show.ended = DateUtilityService.parse_date(show_data['ended'])
      show.official_site = show_data['officialSite']
      show.rating = show_data.dig('rating', 'average')
      show.genres = show_data['genres']&.join(', ')
      show.schedule_time = show_data.dig('schedule', 'time')
      show.schedule_days = show_data.dig('schedule', 'days')&.join(', ')
      show.image_medium = show_data.dig('image', 'medium')
      show.image_original = show_data.dig('image', 'original')
      show.summary = show_data['summary']
      show.network = network
    end
  end
end
