class ShowSerializer
  def initialize(show)
    @show = show
  end

  def as_json
    {
      id: show.id,
      name: show.name,
      type: show.show_type,
      language: show.language,
      status: show.status,
      rating: show.rating,
      genres: show.genres&.split(', '),
      image_medium: show.image_medium,
      image_original: show.image_original,
      network: network_json
    }
  end

  private

  attr_reader :show

  def network_json
    return nil unless show.network

    {
      id: show.network.id,
      name: show.network.name,
      country: show.network.country
    }
  end
end
