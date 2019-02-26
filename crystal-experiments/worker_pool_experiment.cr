# crystal build --release --no-debug worker_pool_experiment.cr  && time ./httpbin_experiment

require "./test_data"
require "http/client"

WORKER_COUNT = 100

to_fetch = Channel(Array(String)?).new(WORKER_COUNT)
responses = Channel(Bool?).new(WORKER_COUNT)

WORKER_COUNT.times do
  spawn do
    loop do
      urls = to_fetch.receive


        result = if urls
          urls.each {|url|  HTTP::Client.get(url)}

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
  SHUFFLED_LINKS.each_slice(5) do |links|
    to_fetch.send links
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
puts "#{SHUFFLED_LINKS.size} links"
