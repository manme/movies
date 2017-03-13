class MoviesFacade
  attr_reader :current_user,
              :movies,
              :movie,
              :page

  def initialize(current_user, page = nil, per_page = 10)
    @current_user = current_user
    @page = page
    @per_page = per_page
    @movie_ids = []
  end

  def all(movies = nil)
    @movies = movies
    @movies ||= Movie.all
    @movies = @movies.order(created_at: :desc).active.to_a

    # TO-DO: change to where(movies.id > last_id).limit(10)
    # because this pagination with sql offsets is a bad way
    # http://use-the-index-luke.com/no-offset
    @movies = @movies.paginate(page: @page, per_page: @per_page)
    @movie_ids = @movies.map { |movie| movie.id }
  end

  def find(movie_id)
    @movie = Movie.active.find(movie_id)
    @movie_ids = [movie_id]
  end

  def can_vote?(movie)
    return false if @current_user.nil?
    user_movies_rating[movie.id].nil?
  end

  def categories_for(movie)
    movies_categories[movie.id]
  end

  def movies_categories
    @movies_categories ||= Movie.categories_for(@movie_ids)
  end

  def user_movies_rating
    @user_movies_rating ||= MoviesVote.scores_for(@movie_ids, @current_user.id)
  end
end
