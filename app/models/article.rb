# frozen_string_literal: true

class Article < ApplicationRecord
  include PgSearch::Model

  scope :ordered, -> { order(created_at: :desc) }

  validates :title, presence: true
  validates :content, presence: true

  pg_search_scope :pg_search,
                  against: %i[title content],
                  ignoring: :accents,
                  using: {
                    tsearch: {
                      dictionary: 'custom_pt_br',
                      tsvector_column: 'tsv'
                    }
                  }

  class << self
    def bad_search(term)
      if term.present?
        self.where(
          %(
            unaccent(title) ilike unaccent(:term)
            OR unaccent(content) ilike unaccent(:term)
          ),
          term: "%#{term}%"
        )
      else
        self.all
      end
    end

    def good_search(term)
      if term.present?
        self.pg_search(term)
      else
        self.all
      end
    end
  end
end
