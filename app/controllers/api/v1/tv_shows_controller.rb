class Api::V1::TvShowsController < ApplicationController
  before_action :set_cache_headers

  def index
    @episodes = TvShowsQueryService.new(params).call

    render json: {
      data: @episodes.map { |episode| EpisodeSerializer.new(episode).as_json },
      pagination: pagination_json
    }
  end

  def shows
    @shows = TvShow.includes(:network)
                   .joins(:episodes)
                   .distinct
                   .order(:name)
                   .page(params[:page] || 1)
                   .per(params[:per_page] || 50)

    render json: {
      data: @shows.map { |show| ShowSerializer.new(show).as_json },
      pagination: shows_pagination_json
    }
  end

  def show_episodes
    @show = TvShow.find(params[:id])
    @episodes = @show.episodes
                     .includes(:tv_show, :release_dates)
                     .joins(:release_dates)
                     .order('release_dates.airdate DESC, episodes.season DESC, episodes.episode_number DESC')
                     .page(params[:page] || 1)
                     .per(params[:per_page] || 25)

    render json: {
      show: ShowSerializer.new(@show).as_json,
      data: @episodes.map { |episode| EpisodeSerializer.new(episode).as_json },
      pagination: episodes_pagination_json
    }
  end

  def networks
    @networks = Distributor.joins(:tv_shows)
                          .select(:name)
                          .distinct
                          .order(:name)

    render json: {
      data: @networks.pluck(:name)
    }
  end

  def countries
    @countries = Distributor.joins(:tv_shows)
                           .select(:country)
                           .distinct
                           .where.not(country: nil)
                           .order(:country)

    render json: {
      data: @countries.pluck(:country)
    }
  end

  private

  def pagination_json
    per_page = [params[:per_page]&.to_i || 25, 100].min
    {
      current_page: @episodes.current_page,
      total_pages: @episodes.total_pages,
      total_count: @episodes.total_count,
      per_page: per_page
    }
  end

  def shows_pagination_json
    per_page = [params[:per_page]&.to_i || 50, 100].min
    {
      current_page: @shows.current_page,
      total_pages: @shows.total_pages,
      total_count: @shows.total_count,
      per_page: per_page
    }
  end

  def episodes_pagination_json
    per_page = [params[:per_page]&.to_i || 25, 100].min
    {
      current_page: @episodes.current_page,
      total_pages: @episodes.total_pages,
      total_count: @episodes.total_count,
      per_page: per_page
    }
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "public, max-age=3600"
    response.headers["Vary"] = "Accept"
  end
end
