require "./test_data"
require "http/client"

start = Time.now

ch = Channel(Nil).new(100)
schedule_ch = Channel(Nil).new

SHUFFLED_LINKS.each_slice(5) do |links|
  spawn do
#    schedule_ch.receive

    links.each do |link|
      response = HTTP::Client.get link
#      puts response.status_code      # => 200
    end

#    schedule_ch.send(nil)
    ch.send(nil)
  end
end

#140.times { schedule_ch.send(nil) }
(SHUFFLED_LINKS.size / 5).times { ch.receive }


puts "#{Time.now - start} seconds"
puts "Links: #{SHUFFLED_LINKS.size}"