# frozen_string_literal: true

require 'rails_helper'

  RSpec.describe Article, type: :model do
  describe 'included' do
    it { is_expected.to have_included(PgSearch::Model) }
  end

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

  describe 'searchs' do
    before { allow(described_class).to receive(:all) }

    describe '.bad_search' do
      before do
        allow(described_class).to receive(:where)
        described_class.bad_search(term)
      end

      context 'when term is null' do
        let(:term) { nil }

        it { expect(described_class).to have_received(:all) }
        it { expect(described_class).not_to have_received(:where) }
      end

      context 'when term is null' do
        let(:term) { 'teste' }

        it { expect(described_class).not_to have_received(:all) }
        it { expect(described_class).to have_received(:where).with(
          %(
            unaccent(title) ilike unaccent(:term)
            OR unaccent(content) ilike unaccent(:term)
          ),
          term: "%#{term}%"
        ) }
      end
    end

    describe '.good_search' do
      before do
        allow(described_class).to receive(:pg_search)
        described_class.good_search(term)
      end

      context 'when term is null' do
        let(:term) { nil }

        it { expect(described_class).to have_received(:all) }
        it { expect(described_class).not_to have_received(:pg_search) }
      end

      context 'when term is null' do
        let(:term) { 'teste' }

        it { expect(described_class).not_to have_received(:all) }
        it { expect(described_class).to have_received(:pg_search).with(term) }
      end
    end
  end
end
