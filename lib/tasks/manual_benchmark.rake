# frozen_string_literal: true

require 'faraday'

present_words = File.readlines('lib/tasks/present_words.txt').map{ |word| word.chomp }
url = 'http://localhost:3000/v1/articles'

namespace :manual_benchmark do
  task method: :environment do
    puts "\n######### Method - Manual Benchmark #########"
    puts "context       average       total"

    average = 0.0
    global_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    present_words.each do |word|
      single_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      Article.bad_search(word).count
      single_finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      average += single_finish - single_start
    end
    global_finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    total = global_finish - global_start
    average /= present_words.count
    puts "  bad         #{'%.4f' % average}s       #{'%.4f' % total}s"

    average = 0.0
    global_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    present_words.each do |word|
      single_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      Article.good_search(word).count
      single_finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      average += single_finish - single_start
    end
    global_finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    total = global_finish - global_start
    average /= present_words.count
    puts "  good        #{'%.4f' % average}s       #{'%.4f' % total}s"
  end

  task request: :environment do
    puts "\n######### Request - Manual Benchmark ########"
    puts "context       average       total"

    average = 0.0
    global_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    present_words.each do |word|
      single_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      Faraday.get(url, { q: word }, { 'Accept' => 'application/json' })
      single_finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      average += single_finish - single_start
    end
    global_finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    total = global_finish - global_start
    average /= present_words.count
    puts "  bad         #{'%.4f' % average}s       #{'%.4f' % total}s"

    average = 0.0
    global_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    present_words.each do |word|
      single_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      Faraday.get(url, { q: word, good_search: 'ok' }, { 'Accept' => 'application/json' })
      single_finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      average += single_finish - single_start
    end
    global_finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    total = global_finish - global_start
    average /= present_words.count
    puts "  good        #{'%.4f' % average}s       #{'%.4f' % total}s"
  end

  task all: :environment do
    Rake::Task['manual_benchmark:method'].execute
    Rake::Task['manual_benchmark:request'].execute
  end
end
