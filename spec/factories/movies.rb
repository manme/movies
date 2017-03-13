# == Schema Information
#
# Table name: movies
#
#  id           :integer          not null, primary key
#  title        :string           not null
#  description  :text             not null
#  user_id      :integer
#  is_deleted   :boolean          default("false")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  total_score  :integer          default("0")
#  avg_score    :float            default("0.0")
#  votes_number :integer          default("0")
#

FactoryGirl.define do
  factory :movie do
    title Faker::Lorem.sentence
    description Faker::Lorem.paragraph
  end
end
