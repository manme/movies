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

require 'rails_helper'

RSpec.describe MoviesVote, type: :model do
  describe '.scores_for' do
    subject { described_class }
    let(:user) { create(:user) }
    let(:movies) { create_list(:movie, 3, user: user) }
    let(:movie_ids) { movies.map(&:id) }
    let(:movies_votes) do
      movies.each_with_index do |movie|
        create(:movies_vote, user: user, movie: movie, score: movie.id * 2)
      end
    end

    before do
      movies_votes
    end

    it 'has scores for movies' do
      movies_votes = movie_ids.each_with_object({}) { |id, m| m[id] = id * 2 }
      expect(subject.scores_for(movie_ids, user.id)).to eq(movies_votes)
    end
  end
end
