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

require 'rails_helper'

RSpec.describe Movie, type: :model do
  let(:user) { create(:user) }
  let(:movies) { create_list(:movie, @movie_count, user: user) }
  subject { described_class }

  describe '.search_for' do
    before do
      @movie_count = 10
      movies
    end

    it 'find in description' do
      expect(subject.search_for(movies.first.description.split(' ').first).to_a)
        .to include(movies.first)
    end

    it 'find in title' do
      expect(subject.search_for(movies.first.title.split(' ').first).to_a)
        .to include(movies.first)
    end
  end

  describe '.for_score' do
    before do
      @movie_count = 5
      movies.each_with_index do |movie, i|
        movie.update(avg_score: i + 0.5)
      end
    end

    it 'find in description' do
      @movie_count.times do |i|
        expect(subject.for_score(i).first).to eq(movies[i])
      end
    end
  end

  describe '#delete' do
    before do
      @movie_count = 1
      movies
    end

    it 'sets is_deleted to movies' do
      expect { movies.first.delete }.to change { subject.active.count }.from(1).to(0)
    end
  end

  describe '#save_categories' do
    let(:categories) { Faker::Hipster.words }

    before do
      @movie_count = 1
      movies
    end

    it 'creates categories for movies' do
      expect { movies.first.save_categories(categories) }
        .to change { movies.first.reload.category_list }.from([]).to(categories)
    end
  end

  describe '.for_categories' do
    let(:categories) { Faker::Hipster.words }

    before do
      @movie_count = 10
      movies.each do |movie|
        movie.save_categories(categories)
      end
    end

    it 'returns all movies for categories' do
      expect(subject.for_categories(categories).pluck(:id).uniq).to match_array(subject.all.pluck(:id))
    end

    it 'has not movies for categories' do
      expect(subject.for_categories(Faker::Lorem.words).pluck(:id)).to eq([])
    end
  end

  describe '.for_scores' do
    let(:scores) { subject.all_scores }

    before do
      @movie_count = 5
      movies.each_with_index do |movie, index|

        movie.update(avg_score: scores[index])
      end
    end

    it 'returns all movies for scores' do
      expect(subject.for_scores(scores).pluck(:id)).to match_array(subject.all.pluck(:id))
    end

    it 'returns one movie for score' do
      expect(subject.for_scores([scores.first]).pluck(:id)).to eq([movies.first.id])
    end

    it 'returns all movies for scores' do
      expect(subject.for_scores((11..20).to_a).pluck(:id)).to eq([])
    end
  end

  describe '.all_categories_with_count' do
    let(:categories) { Faker::Hipster.words(10) }
    let(:categories_count) { {} }

    before do
      @movie_count = 10
      movies.each do |movie|
        movie.save_categories(categories)
        categories.each do |c|
          categories_count[c] ||= 0
          categories_count[c] += 1
        end
      end
    end

    it 'returns all movies for categories' do
      expect(subject.all_categories_with_count).to eq(categories_count)
    end
  end

  describe '.all_scores_with_count' do
    let(:scores) { subject.all_scores }
    let(:scores_count) { {} }

    before do
      @movie_count = 5
      movies.each_with_index do |movie, index|
        movie.update(avg_score: scores[index])
        scores_count[scores[index]] ||= 0
        scores_count[scores[index]] += 1
      end
    end

    it 'returns all movies for categories' do
      expect(subject.all_scores_with_count).to eq(scores_count)
    end
  end

  describe '.categories_for' do
    let(:categories) { Faker::Hipster.words(10) }
    let(:movies_categories) { {} }

    before do
      @movie_count = 10
      movies.each_with_index do |movie, i|
        movie.save_categories([categories[i]])
        movies_categories[movie.id] = [categories[i]]
      end
    end

    it 'returns all movies for categories' do
      categories_h = movies_categories.first(5).each_with_object({}) { |v, m| m[v.first] = v.second }
      expect(subject.categories_for(movies.pluck(:id).first(5))).to eq(categories_h)
    end
  end

  describe 'scorable' do
    # to run only this test should be uncommented the following line
    require 'concerns/scorable_spec'

    it_behaves_like 'scorable'
  end
end
