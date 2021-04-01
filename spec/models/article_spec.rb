# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Article, type: :model do
  describe 'validates' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:content) }
  end

  describe 'scopes' do
    context 'when ordered' do
      it 'is expected to order by created_at desc' do
        expect(described_class.ordered.to_sql).to eq(%(SELECT "articles".* FROM "articles" ORDER BY "articles"."created_at" DESC))
      end
    end
  end
end
