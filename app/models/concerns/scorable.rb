module Scorable
  extend ActiveSupport::Concern

  def int_score
    avg_score.to_i
  end

  def score_number
    avg_score.round(1)
  end

  # make vote and save score for current movie
  def score_for!(user, score)
    raise 'score is not valid' unless (1..self.class::SCORE_MAX).to_a.include?(score)

    ActiveRecord::Base.transaction do
      unless MoviesVote.exists?(movie_id: self.id, user_id: user.id)
        MoviesVote.create!(movie_id: self.id, user_id: user.id, score: score)
        update_score!(score)
      end
    end
  end

  def new_score_params(score)
    new_total_score = total_score + score
    new_votes_number = votes_number + 1
    avg_score = new_total_score.to_f / new_votes_number

    {
      total_score: new_total_score,
      votes_number: new_votes_number,
      avg_score: avg_score
    }
  end

  module ClassMethods
    def all_scores
      @all_scores ||= (1..self::SCORE_MAX).to_a
    end
  end

  private

  def update_score!(score)
    self.update(new_score_params(score))
  end
end