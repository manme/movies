require 'rails_helper'

describe MoviesFacade do
  subject { described_class.new(@current_user, @page) }
  let(:user) { create(:user) }
  let(:movies) { create_list(:movie, 50, user: user) }
  let(:movie_deleted) { create(:movie, user: user, is_deleted: true) }
  let(:movie_active) { create(:movie, user: user) }

  describe '#all' do
    context 'all movies' do
      let(:created_at) { subject.movies.pluck(:created_at) }

      before do
        @current_user = nil
        @page = nil
        movies
      end

      it 'default' do
        expect(subject.movies).to be_nil
      end

      it 'loaded' do
        expect{subject.all}.to change{subject.movies.try(:count)}.from(nil).to(10)
      end

      it 'ordered by created_at' do
        subject.all
        expect(created_at).to eq(Movie.order(created_at: :desc).pluck(:created_at).first(10))
      end
    end

    context 'movies with pagination' do
      let(:movies_for_page) { Movie.order(created_at: :desc).pluck(:id) }

      before do
        @current_user = nil
        @page = 2
        movies
        subject.all
      end

      it 'for second page' do
        expect(subject.movies.pluck(:id)).to eq(movies_for_page.slice(10, 10))
        expect(subject.movies.class).to eq(WillPaginate::Collection)
      end
    end

    context 'movies with filters' do
      let(:filter_movies) { Movie.limit(5).order(:created_at) }

      before do
        movies
        subject.all(filter_movies)
      end

      it 'loaded' do
        expect(subject.movies).to match_array(filter_movies)
      end
    end

    context 'active movies' do
      before do
        movie_deleted
        movie_active
        subject.all(Movie.all)
      end

      it { expect(subject.movies).to eq([movie_active]) }
    end
  end

  describe '#find' do
    context 'movie for id' do
      before do
        movies
        subject.find(movies.first.id)
      end

      it { expect(subject.movie).to eq(movies.first) }
    end

    context 'deleted movie for id' do
      before do
        movie_deleted
      end

      it { expect{subject.find(movie_deleted.id)}.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end

  describe '#can_vote?' do
    context 'when not authorized' do
      before do
        @current_user = nil
        movies
        subject.all
      end

      it 'can not vote' do
        expect(subject.can_vote?(subject.movies.first)).to be false
      end
    end

    context 'when authorized' do
      context 'can vote' do
        before do
          @current_user = user
          movies
          subject.all
        end

        it { expect(subject.can_vote?(subject.movies.first)).to be true }
      end

      context 'cant vote again' do
        let(:vote) { create(:movies_vote, user: user, movie: subject.movies.first, score: 0) }

        before do
          @current_user = user
          movies
          subject.all
          vote
        end

        it { expect(subject.can_vote?(subject.movies.first)).to be false }
      end
    end
  end

  describe '#categories_for' do
    let(:categories) { Faker::Hipster.words }

    before do
      @current_user = user
      movies
      subject.all
      subject.movies.first.save_categories(categories)
    end

    it 'return categories' do
      expect(subject.categories_for(subject.movies.first)).to match_array(categories)
    end
  end
end