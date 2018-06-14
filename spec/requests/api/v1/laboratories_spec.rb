require 'rails_helper'

RSpec.describe 'Laboratory API' do
  before { host! 'api.taskmanager.dev' }

  let!(:user) { create(:user) }
  let(:headers) do
		{
		  'Content-Type' => Mime[:json].to_s,
		  'Accept' => 'application/vnd.taskmanager.v1',
		  'Authorization' => user.auth_token
		}
  end


  describe 'GET /laboratories' do
    before do
      create_list(:laboratory, 5, user_id: user.id)
      get '/laboratories', params: {}, headers: headers
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'returns 5 laboratories from database' do
      expect(json_body[:laboratories].count).to eq(5)
    end
  end


  describe 'GET /laboratories/:id' do
    let(:laboratory) { create(:laboratory, user_id: user.id) }

    before { get "/laboratories/#{laboratory.id}", params: {}, headers: headers }

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'returns the json for laboratory' do
      expect(json_body[:title]).to eq(laboratory.title)
    end
  end


  describe 'POST /laboratories' do
    before do
      post '/laboratories', params: { laboratory: laboratory_params }.to_json, headers: headers
    end

    context 'when the params are valid' do
      let(:laboratory_params) { attributes_for(:laboratory) }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'saves the laboratory in the database' do
        expect( Laboratory.find_by(title: laboratory_params[:title]) ).not_to be_nil
      end

      it 'returns the json for created laboratory' do
        expect(json_body[:title]).to eq(laboratory_params[:title])
      end

      it 'assigns the created laboratory to the current user' do
        expect(json_body[:user_id]).to eq(user.id)
      end      
    end

    context 'when the params are invalid' do
      let(:laboratory_params) { attributes_for(:laboratory, title: ' ') }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'does not save the laboratory in the database' do
        expect( Laboratory.find_by(title: laboratory_params[:title]) ).to be_nil
      end

      it 'returns the json error for title' do
        expect(json_body[:errors]).to have_key(:title)
      end
    end
  end

  
  describe 'PUT /laboratories/:id' do
    let!(:laboratory) { create(:laboratory, user_id: user.id) }

    before do
      put "/laboratories/#{laboratory.id}", params: { laboratory: laboratory_params }.to_json, headers: headers
    end

    context 'when the params are valid' do
      let(:laboratory_params){ { title: 'New laboratory title' } }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the json for updated laboratory' do
        expect(json_body[:title]).to eq(laboratory_params[:title])
      end

      it 'updates the laboratory in the database' do
        expect( Laboratory.find_by(title: laboratory_params[:title]) ).not_to be_nil
      end
    end

    context 'when the params are invalid' do
      let(:laboratory_params){ { title: ' '} }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns the json error for title' do
        expect(json_body[:errors]).to have_key(:title)
      end

      it 'does not update the laboratory in the database' do
        expect( Laboratory.find_by(title: laboratory_params[:title]) ).to be_nil
      end
    end
  end


  describe 'DELETE /laboratories/:id' do
    let!(:laboratory) { create(:laboratory, user_id: user.id) }

    before do
      delete "/laboratories/#{laboratory.id}", params: {}, headers: headers
    end

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end

    it 'removes the laboratory from the database' do
      expect { Laboratory.find(laboratory.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end