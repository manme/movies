require 'rails_helper'

describe FilterMoviesFacade do
  subject { described_class.new(@filter_params) }
  let(:scores) { (1..5).to_a }
  let(:categories) { Faker::Lorem.words(4) }
  let(:text_search) { Faker::Lorem.word }

  describe '#movies' do
    let(:user) { create(:user) }
    let(:movies) { create_list(:movie, @movies_count, user: user) }
    let(:categories) do
      Array.new(@movies_count, Faker::Hipster.words(5))
    end
    let(:scores) do
      (1..@movies_count).to_a
    end

    before do
      @movies_count = 10

      movies.each_with_index do |movie, i|
        movie.save_categories(categories[i])
        movie.update(avg_score: scores[i])
      end

      @filter_params = {
        scores: scores.slice(0, 1),
        categories: categories.first,
        text_search: movies.first.title.split(' ').first
      }
    end

    it 'has one movie for all filters' do
      expect(subject.movies.to_a).to include(movies.first)
    end
  end

  describe '#filters' do
    context 'for one filter param' do
      let(:filter_hash) do
        {
          scores: Movie.method(:for_scores)
        }
      end

      before do
        @filter_params = { scores: scores }
      end

      it 'make hash with methods' do
        expect(subject.filters).to eq(filter_hash)
      end
    end

    context 'for all filter params' do
      let(:filter_hash) do
        {
          categories: Movie.method(:for_categories),
          scores: Movie.method(:for_scores),
          text_search: Movie.method(:search_for)
        }
      end

      before do
        @filter_params = {
          scores: scores,
          categories: categories,
          text_search: text_search
        }
      end

      it 'make hash with methods' do
        expect(subject.filters).to eq(filter_hash)
      end
    end
  end

  describe '#filter_rating_selected_for' do
    before do
      @filter_params = { scores: scores }
    end

    it 'is "selected" for name' do
      expect(subject.filter_rating_selected_for(scores.first))
        .to eq('selected')
    end

    it 'is nil for name' do
      expect(subject.filter_rating_selected_for(10))
        .to be_nil
    end
  end

  describe '#filter_categories_selected_for' do
    before do
      @filter_params = { categories: categories }
    end

    it 'is "selected" for name' do
      expect(subject.filter_categories_selected_for(categories.first))
        .to eq('selected')
    end

    it 'is nil for name' do
      expect(subject.filter_categories_selected_for('some_category'))
        .to be_nil
    end
  end

  describe '#categories_statistics' do
    before do
      @filter_params = {}
    end

    it 'call movie method' do
      expect(Movie).to receive(:all_categories_with_count)
      subject.categories_statistics
    end

    it 'return hash' do
      expect(subject.rating_statistics.class).to eq(Hash)
    end
  end

  describe '#rating_statistics' do
    before do
      @filter_params = {}
    end

    it 'call movie method' do
      expect(Movie).to receive(:all_scores_with_count)
      subject.rating_statistics
    end

    it 'return hash' do
      expect(subject.rating_statistics.class).to eq(Hash)
    end
  end
end
