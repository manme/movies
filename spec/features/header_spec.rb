require 'rails_helper'

feature 'Header' do
  let(:user) { create(:user) }

  feature 'Auth links' do
    context 'user is not signed in' do
      scenario do
        visit '/'
        expect(has_link?('Sign in')).to be true
        expect(has_link?('Sign up')).to be true
        expect(has_link?('Add Movie')).to be false
        expect(has_link?('Edit Profile')).to be false
        expect(has_link?('Sign out')).to be false
      end
    end

    context 'user is signed in' do
      scenario do
        login_as(user, scope: :user)
        visit '/'
        expect(has_link?('Edit Profile')).to be true
        expect(has_link?('Sign out')).to be true
        expect(has_link?('Add Movie')).to be true
        expect(has_link?('Sign in')).to be false
        expect(has_link?('Sign up')).to be false
      end
    end
  end
end
