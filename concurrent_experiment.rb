require './test_data'

require 'concurrent'
require 'timeout'
require 'net/http'

start = Time.now

# pool = Concurrent::FixedThreadPool.new(20)
pool = Concurrent::CachedThreadPool.new

SHUFFLED_LINKS.first(250).each_slice(5).with_index do |links, index|
  pool.post do
    # puts index
    links.each do |link|
      begin
        Timeout::timeout(5) do
          Net::HTTP.get_response(URI(link)).code
        end
        sleep 1
      rescue => e
        puts "Link with error: #{link}"
        puts e.message
        nil
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