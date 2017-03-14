require 'rails_helper'

feature 'Auth' do
  let(:user) do
    create(
      :user,
      email: email,
      password: password,
      password_confirmation: password
    )
  end

  let(:password) { Faker::Internet.password }
  let(:email)    { Faker::Internet.email }

  let(:new_password) { Faker::Internet.password }
  let(:new_email)    { Faker::Internet.email }

  def fill_edit
    fill_in 'Email', with: new_email
    fill_in 'Password', with: new_password
    fill_in 'Password Confirmation', with: new_password
    fill_in 'Current Password', with: password
  end

  def fill_sign_in
    fill_in 'Password', with: password
    fill_in 'Email', with: email
  end

  def fill_sign_up
    fill_in 'Password', with: password
    fill_in 'Password Confirmation', with: password
    fill_in 'Email', with: email
  end

  feature 'sign in' do
    context 'user does not exist' do
      scenario do
        visit '/users/sign_in'

        expect { click_on 'Sign in' }.not_to change { User.count }
        expect(current_path).to eq('/users/sign_in')
        expect(page).to have_selector('.alert-danger')
      end
    end

    context 'user exists' do
      before do
        user
      end

      scenario do
        visit '/users/sign_in'
        fill_sign_in
        expect { click_on 'Sign in' }.not_to change { User.count }
        expect(current_path).to eq('/')
        expect(has_link?('Sign out')).to be true
      end
    end
  end

  feature 'sign up' do
    context 'user does not exist' do
      scenario do
        visit '/users/sign_up'
        fill_sign_up

        expect { click_on 'Sign up' }.to change { User.count }.by(1)
        expect(current_path).to eq('/')
        expect(has_link?('Sign out')).to be true
      end
    end

    context 'user exists' do
      before do
        user
      end

      scenario do
        visit '/users/sign_up'
        fill_sign_up

        expect { click_on 'Sign up' }.not_to change { User.count }
        expect(current_path).to eq('/users')
        expect(page).to have_selector('.alert-danger')
      end
    end
  end

  feature 'edit profile' do
    context 'user exists' do
      before { login_as(user, scope: :user) }

      scenario do
        visit '/users/edit'
        fill_edit

        expect { click_on 'Save' }.not_to change { User.count }
        expect(current_path).to eq('/')
        expect(page).to have_selector('.alert-danger')
      end
    end
  end

  feature 'sign out' do
    before { login_as(user, scope: :user) }

    scenario do
      visit '/'

      expect { click_on 'Sign out' }.not_to change { User.count }
      expect(current_path).to eq('/')
      expect(has_link?('Sign out')).to be false
    end
  end
end
