require 'rails_helper'

# https://github.com/rails/rails/issues/18950
describe MoviesController do
  let(:movies) { create_list(:movie, 50, user: user) }
  let(:movie) { create(:movie, user: user) }
  let(:user) { create(:user) }

  describe 'GET #index' do
    let(:filters) do
      {
        text_search: Faker::Hipster.word,
        scores: (1..5).to_a,
        categories: Faker::Hipster.words
      }
    end

    before do
      movies
    end

    it 'shows movies' do
      get :index
      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq('text/html')
    end

    it 'shows movies for js response' do
      get :index, xhr: true
      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq('text/javascript')
    end

    it 'shows movies for page and params' do
      get :index, params: { page: 1 }.merge(filters)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    before do
      get :show, id: movie
    end

    it 'shows movie' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    context 'authorized access' do
      it 'shows form for new movie' do
        sign_in user
        get :new
        expect(response).to have_http_status(:success)
      end
    end

    context 'guest access' do
      it 'requires login' do
        get :new
        expect(response).to redirect_to(:new_user_session)
      end
    end
  end

  describe 'POST #create' do
    let(:movie_attr) { FactoryGirl.attributes_for(:movie, user: user) }

    context 'authorized access' do
      it 'shows form for new movie' do
        sign_in user
        post :create, movie: movie_attr
        expect(response).to redirect_to(:movies)
      end
    end

    context 'guest access' do
      it 'requires login' do
        post :create, movie: movie_attr
        expect(response).to redirect_to(:new_user_session)
      end
    end
  end

  describe 'GET #edit' do
    context 'authorized access' do
      it 'edit form for existing movie' do
        sign_in user
        get :edit, id: movie
        expect(response).to have_http_status(:success)
      end
    end

    context 'guest access' do
      it 'requires login' do
        get :edit, id: movie
        expect(response).to redirect_to(:new_user_session)
      end
    end
  end

  describe 'PUT #update' do
    context 'authorized access' do
      it 'update existing movie' do
        sign_in user
        put :update, id: movie, movie: FactoryGirl.attributes_for(:movie, user: user)
        expect(response).to redirect_to(:movies)
      end
    end

    context 'guest access' do
      it 'requires login' do
        put :update, id: movie, movie: FactoryGirl.attributes_for(:movie, user: user)
        expect(response).to redirect_to(:new_user_session)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'authorized access' do
      it 'set deleted status to movie' do
        sign_in user
        delete :destroy, id: movie
        expect(response).to redirect_to(:movies)
      end
    end

    context 'guest access' do
      it 'requires login' do
        delete :destroy, id: movie
        expect(response).to redirect_to(:new_user_session)
      end
    end
  end

  describe 'POST #vote' do
    let(:vote_resp) do
      {
        int_score: movie.reload.int_score,
        avg_score: movie.avg_score,
        votes_number: movie.votes_number
      }
    end

    context 'authorized access' do
      let(:vote_user) { create(:user) }

      it 'set score to any movie' do
        sign_in user
        post :vote, movie_id: movie, score: 2
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json')
        expect(response.body).to eq(vote_resp.to_json)
      end
    end

    context 'guest access' do
      it 'requires login' do
        post :vote, movie_id: movie, score: 2
        expect(response).to redirect_to(:new_user_session)
      end
    end
  end
end
