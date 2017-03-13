require 'rails_helper'

feature 'edit movie' do
  let(:title) { Faker::Lorem.sentence }
  let(:description) { Faker::Lorem.paragraph }

  def fill_movie_fields
    fill_in 'Title', with: title
    fill_in 'Description', with: description
    find('.selectpicker').find(:xpath, 'option[1]').select_option
    @selected_categories = all('.selectpicker option[selected]').map(&:text)
  end

  let(:user) { create(:user) }
  let(:movie) { create(:movie, user: user) }

  before do
    movie
    movie.save_categories(['action'])
  end

  scenario 'creates movie' do
    login_as user
    visit edit_movie_path(movie)

    categories = page.all('.selectpicker option[selected]').map(&:text)

    # check inputs
    expect(find_field('Title').value).to eq(movie.title)
    expect(find_field('Description').value).to eq(movie.description)
    expect(categories.size).not_to eq(0)

    fill_movie_fields

    expect { click_on 'Save' }.not_to change { Movie.count }
    expect(Movie.last.category_list.to_a.size).to eq(2)
    expect(current_path).to eq(movies_path)

    expect(has_content?(title)).to be true
    expect(has_content?(description)).to be true

    @selected_categories.each do |category|
      expect(has_content?(category)).to be true
    end
  end
end
