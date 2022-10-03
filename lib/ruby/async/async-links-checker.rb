require "async"
require 'async/barrier'
require "async/http/internet"
require "async/http/faraday"
require "async/http/server"
require "async/reactor"

require "concurrent"

require "uri/http"

# Make it the global default:
Faraday.default_adapter = :async_http

require_relative "../support/test_data"

def faraday_example
  Async do |task|
    SHUFFLED_LINKS[0..100].each do |link|
      task.async do |subtask|
        response = Faraday.get link
        response.status
      end
    end
  end
end

def async_process_http
  Async do |task|
    internet = Async::HTTP::Internet.new
    barrier = Async::Barrier.new
    semaphore = Async::Semaphore.new(5, parent: barrier)

    SHUFFLED_LINKS[100..200].each_slice(5).with_index do |links, index|
      semaphore.async do |subtask|
        links.each do |link|
          response = internet.head(link)
          response.status
        end
      end
    end

    barrier.wait
  ensure
    internet&.close
  end
end

def concurrent_experiment
  pool = Concurrent::FixedThreadPool.new(20)
  # pool = Concurrent::CachedThreadPool.new
  results = []

  SHUFFLED_LINKS[200..300].each_slice(5).with_index do |links, index|
    pool.post do
      # puts index
      links.each do |link|
        Timeout.timeout(5) do
          Net::HTTP.get_response(URI(link)).code
        end
      rescue => e
        puts "Link with error: #{link}"
        puts e.message
        nil
      end

      results[index] = 1
    end
  end

  pool.shutdown
  pool.wait_for_termination
end

require "benchmark"

Benchmark.bmbm do |benchmark|
  benchmark.report("faraday") do |count|
    faraday_example
  end

  benchmark.report("async_http") do |count|
    async_process_http
  end

  benchmark.report("concurrent_experiment") do |count|
    async_process_http
  end
end
