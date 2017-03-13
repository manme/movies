# == Schema Information
#
# Table name: movies
#
#  id           :integer          not null, primary key
#  title        :string           not null
#  description  :text             not null
#  user_id      :integer          not null
#  is_deleted   :boolean          default("false")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  total_score  :integer          default("0")
#  avg_score    :float            default("0.0")
#  votes_number :integer          default("0")
#

class Movie < ApplicationRecord
  include PgSearch
  include Scorable

  CATEGORIES = %w(comedy action thriller drama adventure)
  SCORE_MAX = 5

  belongs_to :user
  has_many :movies_votes

  validates :title, presence: true
  validates :user_id, presence: true
  validates :description, presence: true

  pg_search_scope :search_for, against: %i(title description)
  acts_as_ordered_taggable_on :categories

  scope :active, -> { where(is_deleted: false) }

  scope :for_score, ->(score) { where('avg_score >= ? and avg_score < ?', score, score + 1) }

  def save_categories(category_list)
    self.category_list.parser = Movies::CategoriesParser
    self.category_list = category_list
    save
  end

  def delete
    update_attribute(:is_deleted, true)
  end

  class << self
    def for_categories(categories)
      tag_ids = ActsAsTaggableOn::Tag.where(name: categories).pluck(:id)

      Movie.joins(:taggings)
            .where('taggings.tag_id in (?)', tag_ids)
            .where('taggings.context = ?', 'categories')
    end

    def for_scores(scores)
      scores.inject(nil) do |mem, score|
        objects = Movie.for_score(score)

        # merge requests to one
        if mem.nil?
          objects
        else
          mem.or(objects)
        end
      end
    end

    # { tag_name_1=>23, tag_name_2=>0, ... }
    def all_categories_with_count
      ActsAsTaggableOn::Tagging
        .joins(:tag)
        .joins("INNER JOIN movies ON movies.id = taggings.taggable_id AND taggings.taggable_type = 'Movie'")
        .where('movies.is_deleted = false')
        .group('taggings.tag_id, tags.name')
        .count('taggings.tag_id')
    end

    # { 1=>23, 2=>0, ... }
    def all_scores_with_count
      (1..Movie::SCORE_MAX).to_a.each_with_object({}) do |score, mem|
        mem[score] = Movie.for_score(score).count
      end
    end

    # { movie_id_1 => ['category_1','category_2'], ... }
    def categories_for(movie_ids)
      movies_categories = ActsAsTaggableOn::Tagging
                          .where(taggable_id: movie_ids, taggable_type: Movie.name)
                          .joins('left join tags on tags.id = taggings.tag_id')
                          .pluck('taggings.taggable_id', 'tags.name')

      # group by movie_id: { movie_id => [category_name_1,...,category_name_n], ... }
      movies_categories.each_with_object(Hash.new { |h, k| h[k] = [] }) do |(k, v), h|
        h[k] << v
      end
    end
  end
end
