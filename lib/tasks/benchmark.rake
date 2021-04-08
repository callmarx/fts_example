# frozen_string_literal: true

require 'benchmark'
require 'faraday'

present_words = File.readlines('lib/tasks/present_words.txt').map{ |word| word.chomp }
url = 'http://localhost:3000/v1/articles'

namespace :benchmark do
  task method: :environment do
    puts "\n########## Method - Gem Benchmark ###########"
    Benchmark.bm do |benchmark|
      benchmark.report('bad ') do
        present_words.each do |word|
          Article.bad_search(word).count
        end
      end
      benchmark.report('good') do
        present_words.each do |word|
          Article.good_search(word).count
        end
      end
    end
  end

  task request: :environment do
    puts "\n########## Request - Gem Benchmark ##########"
    Benchmark.bm do |benchmark|
      benchmark.report('bad ') do
        present_words.each do |word|
          Faraday.get(url, { q: word }, { 'Accept' => 'application/json' })
        end
      end
      benchmark.report('good') do
        present_words.each do |word|
          Faraday.get(url, { q: word, good_search: 'ok' }, { 'Accept' => 'application/json' })
        end
      end
    end
  end

  task all: :environment do
    Rake::Task['benchmark:method'].execute
    Rake::Task['benchmark:request'].execute
  end
end
