require './test_data'

require 'concurrent'
require 'timeout'
require 'net/http'

require 'async/reactor'
require 'async/http/faraday'
require 'async/http/response'
require 'async/http/server'
require 'async/http/url_endpoint'


require 'async/http/faraday'

Faraday.default_adapter = :async_http

start = Time.now

pool = Concurrent::FixedThreadPool.new(5) # 5 threads

SHUFFLED_LINKS.each_slice(55) do |pool_links|
  pool.post do
    Async::Reactor.run do |task|
      pool_links.each_slice(5).map do |links|
        task.async do |_subtask|
          links.each do |link|
            begin
              response = Faraday.get link, request: { timeout: 5 }
              puts response.status
            rescue => e
              puts "Link with error: #{link}"
              puts e.message

              nil
            end
          end
        end
      end
    end
  end
end

pool.shutdown
pool.wait_for_termination

# 500.times.map do
#   Thread.new do
#     Net::HTTP.start(host, port, use_ssl: true) do |http|
#       res = http.request_get('/ping')
#       p res.code
#     end
#   end
# end.each(&:join)

puts "#{Time.now - start} seconds"
puts "Links: #{SHUFFLED_LINKS.count}"