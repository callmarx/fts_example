# frozen_string_literal: true

class Article < ApplicationRecord
  scope :ordered, -> { order(created_at: :desc) }

  validates :title, presence: true
  validates :content, presence: true
end
