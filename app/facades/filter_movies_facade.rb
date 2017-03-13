class FilterMoviesFacade
  attr_reader :filter_params,
              :categories_statistics,
              :rating_statistics

  def initialize(filter_params)
    @filter_params = filter_params
  end

  # load filtered movies
  def movies
    return nil if filters.empty?

    sql = filters.inject(nil) do |mem, (name, filter)|
      request = filter.call(filter_params[name])

      if mem.nil?
        request
      else
        mem.merge(request)
      end
    end.to_sql

    Movie.from("(#{sql}) movies").select('distinct movies.*')
  end

  def filters
    @filters ||= { categories: Movie.method(:for_categories),
      scores: Movie.method(:for_scores),
      text_search: Movie.method(:search_for)
    }.delete_if { |name, filter| filter_params[name].blank? }
  end

  def filter_rating_selected_for(i)
    filter_params[:scores].try(:include?, i) ? 'selected' : nil
  end

  def filter_categories_selected_for(name)
    filter_params[:categories].try(:include?, name) ? 'selected' : nil
  end

  def categories_statistics
    @categories_statistics ||= Movie.all_categories_with_count
  end

  def rating_statistics
    @rating_statistics ||= Movie.all_scores_with_count
  end
end