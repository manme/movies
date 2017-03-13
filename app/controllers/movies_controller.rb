class MoviesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_facade
  before_action :set_movie, only: [:show, :edit, :update, :destroy]

  def index
    @facade.all(@filter_facade.movies)

    # for loading movies without turbolinks
    respond_to do |format|
      format.js { render layout: false }
      format.html
    end
  end

  def show
  end

  def new
    @movie = current_user.movies.new
  end

  def create
    @movie = current_user.movies.new(movie_params.except(:category_list))
    if @movie.save && @movie.save_categories(movie_categories)
      redirect_to movies_path
    else
      p movie_params
      render :new
    end
  end

  def edit
  end

  def update
    if @facade.movie.update(movie_params)

      redirect_to movies_path
    else
      render :edit
    end
  end

  def destroy
    @facade.movie.delete
    redirect_to movies_path
  end

  def vote
    movie = Movie.find(params[:movie_id])
    movie.score_for!(current_user, params[:score].to_i)

    response = {
      int_score: movie.int_score,
      avg_score: movie.avg_score,
      votes_number: movie.votes_number
    }

    render json: response, status: 200

  rescue
    render nothing: true, status: 500
  end

  private

  def set_facade
    @facade = MoviesFacade.new(current_user, params[:page])
    @filter_facade = FilterMoviesFacade.new(filter_params)
  end

  def set_movie
    @facade.find(params[:id])
  end

  def filter_params
    filter_params = params.slice(:categories, :scores, :text_search)
    filter_params[:categories] = check_filter_categories(filter_params[:categories])
    filter_params[:scores] = check_filter_scores(filter_params[:scores])
    filter_params
  end

  def movie_params
    params.require(:movie).permit(:title, :description, category_list: [])
  end

  def movie_categories
    (movie_params[:category_list] || []).join(',')
  end

  def check_filter_categories(categories)
    return nil unless categories.is_a?(Array) && categories.reject(&:blank?).any?
    categories
  end

  def check_filter_scores(scores)
    return nil unless scores.is_a?(Array)

    scores = (Movie.all_scores & scores.map(&:to_i))

    scores.any? ? scores : nil
  end
end
