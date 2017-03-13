require 'rails_helper'

feature 'create movie' do

  let(:title) { Faker::Lorem.sentence }
  let(:description) { Faker::Lorem.paragraph }

  def fill_movie_fields
    fill_in 'Title',  with: title
    fill_in 'Description', with: description
    find('.selectpicker').find(:xpath, 'option[2]').select_option
    @selected_categories = all('.selectpicker option[selected]').map(&:text)
  end

  let(:user) { create(:user) }

  scenario 'creates movie' do
    login_as user
    visit new_movie_path
    fill_movie_fields

    expect { click_on 'Save' }.to change { Movie.count }.by(1)
    expect(Movie.last.category_list.to_a.size).to eq(1)
    expect(current_path).to eq(movies_path)

    expect(has_content?(title)).to be true
    expect(has_content?(description)).to be true

    @selected_categories.each do |category|
      expect(has_content?(category)).to be true
    end
  end
end
