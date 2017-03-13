require 'rails_helper'

shared_examples_for 'scorable' do
  let(:subject) { described_class }
  let(:user) { create(:user) }
  let(:object) { create(described_class.to_s.underscore.to_sym, { user: user }.merge(scores)) }
  let(:avg_score) { Faker::Number.between(1, 5) + 0.5 }
  let(:scores) do
    {
      total_score: 0,
      votes_number: 0,
      avg_score: 0
    }
  end
  describe '#int_score' do
    before do
      object.update(avg_score: avg_score)
    end

    it { expect(object.int_score).to eq(avg_score.to_i) }
  end

  describe '#score_number' do
    before do
      object.update(avg_score: avg_score)
    end

    it { expect(object.score_number).to eq(avg_score.round(1)) }
  end

  describe '#score_for!' do
    context 'for first vote' do
      let(:scores) do
        {
          total_score: 10,
          votes_number: 2,
          avg_score: 5
        }
      end

      let(:movies_vote) { [user.id, object.id, 2] }

      before do
        object
        p object
      end

      it 'set score' do
        expect { object.score_for!(user, 2) }.to change { object.avg_score }.from(5).to(4)
        expect(MoviesVote.pluck(:user_id, :movie_id, :score).last).to eq(movies_vote)
      end
    end

    context 'for voted object' do
      before do
        object
        object.score_for!(user, 2)
        object.score_for!(user, 5)
      end

      it 'doesnt set score' do
        expect(MoviesVote.count).to eq(1)
        expect(MoviesVote.pluck(:score).last).to eq(2)
        expect(object.reload.avg_score).to eq(2)
        expect(object.reload.total_score).to eq(2)
        expect(object.reload.votes_number).to eq(1)
      end
    end
  end

  describe '.all_scores' do
    it 'array of scores' do
      expect(subject.all_scores).to eq((1..5).to_a)
    end
  end

  describe '#new_score_params' do
    let(:scores) do
      {
        total_score: 20,
        votes_number: 2,
        avg_score: 10
      }
    end

    let(:new_scores) do
      {
        total_score: 26,
        votes_number: 3,
        avg_score: 26 / 3.0
      }
    end

    before do
      object
    end

    it 'value for movie' do
      expect(object.new_score_params(6)).to eq(new_scores)
    end
  end
end
