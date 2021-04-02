# frozen_string_literal: true

class Article < ApplicationRecord
  include PgSearch::Model

  scope :ordered, -> { order(created_at: :desc) }

  validates :title, presence: true
  validates :content, presence: true

  pg_search_scope :pg_search,
                  against: %i[title content],
                  using: {
                    tsearch: {
                      dictionary: 'custom_pt_br',
                      tsvector_column: 'tsv'
                    }
                  }

  class << self
    def bad_search(term)
      entries = all

      if term.present?
        entries = entries.where(
          %(
            unaccent(title) ilike unaccent(:term)
            OR unaccent(content) ilike unaccent(:term)
          ),
          term: "%#{term}%"
        )
      end
      entries
    end

    def good_search(term)
      entries = all
      entries = entries.pg_search(term) if term.present?
      entries
    end
  end
end
