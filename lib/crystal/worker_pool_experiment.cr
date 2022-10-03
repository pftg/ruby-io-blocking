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
require "time"

cross_count = 0

WORKER_COUNT = ARGV.size > 1 ? ARGV[1].to_i : 120
PARTITION_SIZE = ARGV.size > 2 ? ARGV[2].to_i : 20

puts "Workers Count: #{WORKER_COUNT}"

to_fetch = Channel(Tuple(Int32, Array(String))).new(WORKER_COUNT)
responses = Channel(Tuple(Int32, Array(Array(Bool | Float64 | String)))).new(WORKER_COUNT)
to_count = Channel(Int32).new

work_in_progress = 0

Jobs = Hash(Int32, Array(String)).new

# Jobs

def perform_job(urls : Array(String)) : Array(Array(String | Bool | Float64))
  statistics = urls.map do |url|
    client = HTTP::Client.new(URI.parse(url))

    client.dns_timeout = 10.milliseconds
    client.connect_timeout = 500.milliseconds
    client.read_timeout = 5.seconds
    client.write_timeout = 700.milliseconds

    result = [url, false, Float64::INFINITY, ""]
    started_at = Time.utc

    begin
      response = client.get(
      url,
      HTTP::Headers{
      "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
      "Accept-Encoding" => "gzip, deflate, br",
      "Accept-Language" => "en-US,en;q=0.9,ru;q=0.8,uk;q=0.7,de;q=0.6",
      "User-Agent" => "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1"
      }
      )

      result[2] = (Time.utc - started_at).to_f

      if response.status_code >= 200 && response.status_code < 400
        result[1] = true
      else
        result[3] = response.status_message || ""
      end

      rescue e
        result[2] = (Time.utc - started_at).to_f
        result[3] = e.message || "Error"
    end

    result
  end
  statistics
end

spawn do
  loop do
    diff = to_count.receive
    work_in_progress += diff
  end
end


def create_worker(to_fetch, responses, to_count)
  spawn do
    loop do
      idx, urls = to_fetch.receive
      result = Array(Array(String | Bool | Float64)).new

      begin
        to_count.send(1)
        result = perform_job(urls)
        responses.send({idx, result})
      rescue e
        STDERR.puts("Other Error: #{e.message}")
      ensure
        to_count.send(-1)
      end
    end
  end
end

spawn do
  workers = Array(Fiber).new

  WORKER_COUNT.times do
    workers << create_worker(to_fetch, responses, to_count)
  end

  loop do
    workers.each_with_index do |worker, idx|
      if worker.dead?
        puts "Worker #{idx} is dead"
        workers[idx] = create_worker(to_fetch, responses, to_count)
      end
    end

    sleep 5
  end
end

start = Time.utc
responses_count = 0

schedulling = true
count = (LinksProvider.links.size / PARTITION_SIZE).ceil.to_i

spawn do
  LinksProvider.links.each_slice(PARTITION_SIZE).with_index do |links, index|
    Jobs[index] = links
    to_fetch.send({index, links})

    if ((index.to_i * 100) % count) == 0
      puts "Scheduled: #{((index + 1) * 100 / count).to_i}%"
    end
  end

  schedulling = false
end

done = false

spawn name: "fan-in" do
  File.open("result-cr.csv", "w") do |file|
    while schedulling || count > responses_count
      response = responses.receive

      idx, result = response
      file.puts result.map {|result| result.join(", ")}.join("\n")
      responses_count += 1

      Jobs.delete(idx)

      if (responses_count * PARTITION_SIZE) % 200 == 0
        puts "Responses: #{responses_count}"

        working_time = (Time.utc - start).to_f
        if working_time != 0
          speed = (responses_count * PARTITION_SIZE).to_f / working_time
          puts "Speed: #{speed} links per sec"

          eta = (count - responses_count).to_f / speed
          puts "Left #{eta} seconds"
        end
      end
    end
  end
  done = true
end

spawn do
  loop do
    puts "In Progress: #{work_in_progress}"

    if !schedulling && work_in_progress.zero? && count > responses_count
      puts "There is work, and nobody care about it"
      responses_count = count
      Jobs.each do |(idx, value)|
        responses_count -= 1
        to_fetch.send({idx, value})
      end
    end

    sleep schedulling ? 15 : 5
  end
end

while !done
  Fiber.yield
end

puts "#{Time.utc - start} seconds"
puts "#{LinksProvider.links.size} links"
