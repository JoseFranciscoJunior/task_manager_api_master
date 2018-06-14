require 'rails_helper'

RSpec.describe 'Laboratory API' do
  before { host! 'api.taskmanager.dev' }

  let!(:user) { create(:user) }
  let!(:auth_data) { user.create_new_auth_token }
  let(:headers) do
		{
		  'Content-Type' => Mime[:json].to_s,
		  'Accept' => 'application/vnd.taskmanager.v2',
		  'access-token' => auth_data['access-token'],
		  'uid' => auth_data['uid'],
		  'client' => auth_data['client']
		}
  end


  describe 'GET /laboratories' do
    context 'when no filter param is sent' do
      before do
        create_list(:laboratory, 5, user_id: user.id)
        get '/laboratories', params: {}, headers: headers
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns 5 laboratories from database' do
        expect(json_body[:data].count).to eq(5)
      end      
    end


    context 'when filter and sorting params are sent' do
      let!(:notebook_laboratory_1) { create(:laboratory, title: 'Check if the notebook is broken', user_id: user.id) }
      let!(:notebook_laboratory_2) { create(:laboratory, title: 'Buy a new notebook', user_id: user.id) }
      let!(:other_laboratory_1) { create(:laboratory, title: 'Fix the door', user_id: user.id) }
      let!(:other_laboratory_2) { create(:laboratory, title: 'Buy a new car', user_id: user.id) }

      before do
        get '/laboratories?q[title_cont]=note&q[s]=title+ASC', params: {}, headers: headers
      end

      it 'returns only the laboratories matching and in the correct order' do
        returned_laboratory_titles = json_body[:data].map { |t| t[:attributes][:title] }

        expect(returned_laboratory_titles).to eq([notebook_laboratory_2.title, notebook_laboratory_1.title])
      end
    end
  end


  describe 'GET /laboratories/:id' do
    let(:laboratory) { create(:laboratory, user_id: user.id) }

    before { get "/laboratories/#{laboratory.id}", params: {}, headers: headers }

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'returns the json for laboratory' do
      expect(json_body[:data][:attributes][:title]).to eq(laboratory.title)
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
        expect(json_body[:data][:attributes][:title]).to eq(laboratory_params[:title])
      end

      it 'assigns the created laboratory to the current user' do
        expect(json_body[:data][:attributes][:'user-id']).to eq(user.id)
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
        expect(json_body[:data][:attributes][:title]).to eq(laboratory_params[:title])
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