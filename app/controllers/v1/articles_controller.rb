# frozen_string_literal: true

module V1
  class ArticlesController < ApplicationController
    before_action :entry, only: %i[show create update destroy]

    def index
      @entries = Article.ordered
      render json: data_json(@entries), status: :ok
    end

    def show; end

    def create
      if @entry.save
        render json: data_json(@entry), status: :created
      else
        render json: data_error_json(@entry), status: :unprocessable_entity
      end
    end

    def update
      if @entry.update(parameters)
        render json: data_json(@entry), status: :ok
      else
        render json: data_error_json(@entry), status: :unprocessable_entity
      end
    end

    def destroy
      if @entry.destroy
        render json: data_json(@entry), status: :ok
      else
        render json: data_error_json(@entry), status: :unprocessable_entity
      end
    end

    private

    def entry
      param_id = params[:id]
      @entry = param_id.present? ? Article.find(param_id) : Article.new(parameters)
    end

    def parameters
      params.require(:article).permit(%i[title content])
    end

    def data_json(data)
      { data: data }
    end

    def data_error_json(data)
      json = data_json(data)
      json[:errors] = data.errors
      json
    end
  end
end
