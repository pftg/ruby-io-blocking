# crystal build --release --no-debug httpbin_experiment.cr  && time ./httpbin_experiment

require "http/client"
require "json"

WORKER_COUNT = 40

to_fetch = Channel(String?).new(WORKER_COUNT)
responses = Channel(HTTP::Client::Response?).new(WORKER_COUNT)

WORKER_COUNT.times do
  spawn do
    loop do
      url = to_fetch.receive

      5.times do
        responses.send url ? HTTP::Client.get(url) : nil
        sleep 1
      end

      break unless url
    end
  end
end

spawn do
  50.times do |i|
    to_fetch.send "http://httpbin.org/delay/1"
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
#    puts "#{Time.now - start}: fetched #{JSON.parse(response.body)["url"]} => #{response.status_code}"
  else
    worker_done_count += 1
    break if worker_done_count == WORKER_COUNT
  end
end