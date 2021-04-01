# frozen_string_literal: true

Rails.application.routes.draw do
  scope module: 'v1', path: 'v1', as: 'v1', defaults: { format: 'json' } do
    resources :articles
  end
end
