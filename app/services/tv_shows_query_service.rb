class TvShowsQueryService
  def initialize(params)
    @params = params
  end

  def call
    episodes = Episode.includes(includes_hash)
                      .joins(tv_show: :network)
                      .joins(:release_dates)
    episodes = apply_date_filter(episodes)
    episodes = apply_optional_filters(episodes)
    episodes = apply_ordering(episodes)
    apply_pagination(episodes)
  end

  private

  attr_reader :params

  def includes_hash
    {
      tv_show: :network,
      release_dates: []
    }
  end

  def apply_date_filter(episodes)
    raise ArgumentError, 'date_from and date_to parameters are required' unless params[:date_from].present? && params[:date_to].present?

    date_from, date_to = DateUtilityService.safe_date_range(params[:date_from], params[:date_to])
    episodes.where(release_dates: { airdate: date_from..date_to })
  end

  def apply_optional_filters(episodes)
    episodes = filter_by_distributor(episodes) if params[:distributor].present?
    episodes = filter_by_country(episodes) if params[:country].present?
    episodes = filter_by_rating(episodes) if params[:rating].present?
    episodes
  end

  def filter_by_distributor(episodes)
    episodes.where(distributors: { name: params[:distributor] })
  end

  def filter_by_country(episodes)
    episodes.where(distributors: { country: params[:country] })
  end

  def filter_by_rating(episodes)
    episodes.where('tv_shows.rating >= ?', params[:rating].to_f)
  end

  def apply_ordering(episodes)
    episodes.order(
      'release_dates.airdate ASC, release_dates.airtime ASC, tv_shows.name ASC, episodes.season ASC, episodes.episode_number ASC'
    )
  end

  def apply_pagination(episodes)
    page = params[:page]&.to_i || 1
    per_page = [params[:per_page]&.to_i || 25, 100].min
    episodes.page(page).per(per_page)
  end
end
