# crystal build --release --no-debug worker_pool_experiment.cr  && time ./httpbin_experiment


# Stats for real data
# crystal run crystal-experiments/worker_pool_experiment.cr -- top-10k.csv
# 100 Workers
# 00:38:48.663606000 seconds
# 10000 links
# 1000 Workers
# 00:37:42.504293000 seconds
# 10000 links
# 20 Workers
# 00:36:13.548922000 seconds
# 10000 links

require "./test_data"
require "http/client"

WORKER_COUNT = 3000

to_fetch = Channel(Array(String)?).new(WORKER_COUNT)
responses = Channel(Bool?).new(WORKER_COUNT)

WORKER_COUNT.times do
  spawn do
    loop do
      urls = to_fetch.receive

      result = if urls
                 urls.each do |url|
                   uri = URI.parse(url)

                   client = HTTP::Client.new(uri)

                   client.dns_timeout = 1.seconds
                   client.connect_timeout = 5.seconds
                   client.read_timeout = 5.seconds

                   begin
                     response = client.get(uri.full_path || "/")
                   rescue e
                     puts e.message
                   end
                 end

                 true
               else
                 nil
               end

      responses.send result

      break unless urls
    end
  end
end

spawn do
  count = LinksProvider.links.size / 5
  LinksProvider.links.each_slice(5).with_index do |links, index|
    to_fetch.send links

    puts "Scheduled #{index} / #{count} (#{(index * 100 / count)}%)" if (index * 100 % count) == 0
  end

  WORKER_COUNT.times do
    to_fetch.send nil
  end
end

start = Time.now
worker_done_count = 0

loop do
  response = responses.receive
  if response
    #    puts "#{Time.now - start}: fetched => #{response.status_code}"
  else
    worker_done_count += 1
    break if worker_done_count == WORKER_COUNT
  end
end

puts "#{Time.now - start} seconds"
puts "#{LinksProvider.links.size} links"
