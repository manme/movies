require 'rails_helper'

feature 'show movie' do

  let(:user) { create(:user) }
  let(:movie) { create(:movie, user: user, avg_score: 3.8, votes_number: 5, total_score: 19) }
  let(:categories) { Faker::Hipster.words(5) }

  feature 'existing movie' do
    let(:movie_container) { page.find(".movie[data-movie-id='#{movie.id}']") }

    before do
      movie.save_categories(categories)
    end

    context 'for guest' do
      before do
        visit movie_path(movie)
      end

      scenario 'check movie fields' do

        expect(page).to have_content(movie.title)
        expect(page).to have_content(movie.description)

        movie.category_list.each do |category|
          expect(has_content?(category)).to be true
        end

        expect(page).to have_selector('.avg_score', text: movie.score_number)
        expect(movie_container).to have_selector('.votes_number', text: "(#{movie.votes_number})")

        expect(has_css?('.star', count: 5)).to be true
        expect(has_css?('.star.selected', count: 3)).to be true
      end

      scenario 'cant send movies vote', js: true do
        expect(has_css?('.stars.disabled')).to be true
      end
    end

    context 'for authorized user' do
      before do
        login_as user
        visit movie_path(movie)
      end

      scenario 'check movie fields' do

        expect(page).to have_content(movie.title)
        expect(page).to have_content(movie.description)

        movie.category_list.each do |category|
          expect(has_content?(category)).to be true
        end

        expect(page).to have_selector('.avg_score', text: movie.score_number)
        expect(movie_container).to have_selector('.votes_number', text: "(#{movie.votes_number})")

        expect(has_css?('.star', count: 5)).to be true
        expect(has_css?('.star.selected', count: 3)).to be true

        expect(page).to have_link('Edit', href: edit_movie_path(movie))
        expect(page).to have_link('Delete', href: movie_path(movie))
      end

      scenario 'send movie vote', js: true do

        star = page.find('.star[data-index="5"]')
        star.hover
        expect(has_css?('.star[data-index="5"].selected')).to be false
        star.click

        expect(has_css?('.star.selected', count: 4)).to be true
        expect(page).to have_selector('.avg_score', text: 4)
      end
    end
  end
end

