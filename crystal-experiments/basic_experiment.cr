# docker run --rm -it -v $PWD:/app -w /app durosoft/crystal-alpine:latest crystal run basic_experiment.cr

require "./test_data"
require "http/client"

start = Time.now

ch = Channel(Nil).new
schedule_ch = Channel(Nil).new

LinksProvider.links.each_slice(5) do |links|
  spawn do
    #    schedule_ch.receive

    links.each do |link|
      uri = URI.parse(link)

      client = HTTP::Client.new(uri)
      client.dns_timeout = 1.seconds
      client.connect_timeout = 5.seconds
      client.read_timeout = 5.seconds

      begin
        response = client.get(uri.full_path || "/")
      rescue e
        puts e.message
      end

      #      puts response.status_code      # => 200
    end

    #    schedule_ch.send(nil)
    ch.send(nil)
  end
end

# 140.times { schedule_ch.send(nil) }
(LinksProvider.links.size / 5).times { ch.receive }

puts "#{Time.now - start} seconds"
puts "Links: #{SHUFFLED_LINKS.size}"
