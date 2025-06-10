class Distributor < ApplicationRecord
  has_many :tv_shows, foreign_key: :network_id, dependent: :destroy

  validates :name, presence: true
  validates :tvmaze_id, presence: true, uniqueness: true

  scope :by_country, ->(country) { where(country: country) }

  def self.find_or_create_by_tvmaze_data(network_data)
    return nil unless network_data

    find_or_create_by(tvmaze_id: network_data['id']) do |distributor|
      distributor.name = network_data['name']
      distributor.country = network_data.dig('country', 'name')
      distributor.official_site = network_data['officialSite']
    end
  end
end
