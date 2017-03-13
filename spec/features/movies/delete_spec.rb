require 'rails_helper'

feature 'delete movie' do

  let(:user) { create(:user) }
  let(:movies) { create_list(:movie, 5, user: user, avg_score: 3.5, votes_number: 5) }
  let(:movie) { movies.first }

  before do
    movies
  end

  scenario 'creates movie' do
    login_as user
    visit movies_path

    before_count = page.all(".movie").size
    link = page.find(".movie[data-movie-id='#{movie.id}']")
    link.click_on 'Delete'
    expect(page.all(".movie").size).to eq(before_count - 1)
    expect(has_css?(".movie[data-movie-id='#{movie.id}']")).to be false
    expect(current_path).to eq(movies_path)
  end
end