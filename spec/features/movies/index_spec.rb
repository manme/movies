require 'rails_helper'

feature 'index movies' do
  let(:user) { create(:user) }
  let(:movies) { create_list(:movie, 50, user: user, avg_score: 3.8, votes_number: 5, total_score: 19) }
  let(:categories) { Faker::Hipster.words(5) }

  feature 'empty movie list' do
    scenario 'check empty movies' do
      visit movies_path
      expect(page).to have_selector('.alert.alert-warning')
    end
  end

  feature 'movies list' do
    before do
      movies.each do |movie|
        movie.save_categories(categories)
      end

      visit movies_path

      expect(all('.movie').size).to eq(10)
    end

    scenario 'use filters' do
      expect(page).to have_selector('#movies-menu')
    end

    scenario 'use pagination', js: true do
      expect(page).to have_selector('.pagination_style')
      next_page = ".pagination_style a[href='#{movies_path(format: :html, page: 2)}']"
      all(next_page).first.click

      expect(page.status_code).to eq(200)
    end
  end

  feature 'check movie fields' do
    let(:movie) do
      movie_id = page.all('.movie').first['data-movie-id']
      movies.find { |m| m.id = movie_id }
    end

    let(:movie_container) { page.find(".movie[data-movie-id='#{movie.id}']") }

    context 'for guest' do
      before do
        movies
        visit movies_path

        movie
      end

      scenario 'check movie fields' do
        expect(movie_container).to have_content(movie.title)
        expect(movie_container).to have_content(movie.description)
        expect(movie_container).to have_content(movie.category_list.reverse.join(', '))
        expect(movie_container).to have_selector('.avg_score', text: movie.score_number)
        expect(movie_container).to have_selector('.votes_number', text: "(#{movie.votes_number})")

        expect(movie_container.has_css?('.star', count: 5)).to be true
        expect(movie_container.has_css?('.star.selected', count: 3)).to be true
      end

      scenario 'cant send movies vote', js: true do
        expect(movie_container.has_css?('.stars.disabled')).to be true
      end
    end

    context 'for authorized user' do
      before do
        movies

        login_as user
        visit movies_path

        movie
      end

      scenario 'check movie fields' do
        expect(movie_container).to have_content(movie.title)
        expect(movie_container).to have_content(movie.description)
        expect(movie_container).to have_content(movie.category_list.reverse.join(', '))
        expect(movie_container).to have_selector('.avg_score', text: movie.score_number)
        expect(movie_container).to have_selector('.votes_number', text: "(#{movie.votes_number})")

        expect(movie_container.has_css?('.star', count: 5)).to be true
        expect(movie_container.has_css?('.star.selected', count: 3)).to be true

        expect(movie_container).to have_link('Edit', href: edit_movie_path(movie))
        expect(movie_container).to have_link('Delete', href: movie_path(movie))
      end

      scenario 'send movie vote', js: true do
        star = movie_container.find('.star[data-index="5"]')
        star.hover
        expect(movie_container.has_css?('.star[data-index="5"].selected')).to be false
        star.click

        expect(movie_container.has_css?('.star.selected', count: 4)).to be true
        expect(movie_container).to have_selector('.avg_score', text: 4)
      end
    end
  end
end
