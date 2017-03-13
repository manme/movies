# == Schema Information
#
# Table name: movies_votes
#
#  id         :integer          not null, primary key
#  movie_id   :integer          not null
#  user_id    :integer          not null
#  score      :integer          default("0")
#  created_at :datetime
#

class MoviesVote < ApplicationRecord
  belongs_to :user
  belongs_to :movie

  def self.scores_for(movie_ids, current_user_id)
    movies_scores = MoviesVote.
      where(user_id: current_user_id, movie_id: movie_ids).
      pluck(:movie_id, :score)

    movies_scores.inject(Hash.new) do |h, (k,v)|
      h[k] = v
      h
    end
  end
end
