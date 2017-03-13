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

FactoryGirl.define do
  factory :movies_vote do
  end
end
