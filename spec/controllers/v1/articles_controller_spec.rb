# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::ArticlesController, type: :controller do
  let(:entry) { create(:article) }

  describe '#index' do
    before { get :index }

    it 'is expected entries to be an ActiveRecord::Relation' do
      expect(assigns(:entries)).to be_a(ActiveRecord::Relation)
    end

    it 'is expected entries to be the type defined in Article' do
      expect(assigns(:entries).model).to eq(Article)
    end
  end

  describe '#show' do
    before { get :show, params: { id: entry.id } }

    it 'is expected entry to be the type defined in Article' do
      expect(assigns(:entry)).to be_a(Article)
    end
  end

  describe '#create' do
    before { post :create, params: { article: params } }

    context 'when success' do
      let(:params) { { title: 'entry-title', content: 'entry-content' } }

      it 'is expected entry to be the type defined in Article' do
        expect(assigns(:entry)).to be_a(Article)
      end

      it 'is expected status code is 201' do
        expect(response).to have_http_status(:created)
      end
    end

    context 'when fail' do
      let(:params) { { title: nil } }

      it 'is expected status code is 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '#update' do
    before { put :update, params: { article: params, id: entry.id } }

    context 'when success' do
      let(:params) { { title: 'entry-name' } }

      it 'is expected entry to be the type defined in Article' do
        expect(assigns(:entry)).to be_a(Article)
      end

      it 'is expected status code is 200' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when fail' do
      let(:params) { { title: nil } }

      it 'is expected status code is 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '#destroy' do
    context 'when success' do
      before { delete :destroy, params: { id: entry.id } }

      it 'is expected entry to be the type defined in Article' do
        expect(assigns(:entry)).to be_a(Article)
      end

      it 'is expected status code is 200' do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
