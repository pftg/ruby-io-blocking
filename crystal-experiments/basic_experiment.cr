require "./test_data"
require "http/client"

ch = Channel(Nil).new
schedule_ch = Channel(Nil).new

SHUFFLED_LINKS.each_slice(3) do |links|
  spawn do
    schedule_ch.receive
    puts "run"
    links.each do |link|
      response = HTTP::Client.get link
      puts response.status_code      # => 200
      schedule_ch.send(nil)
      ch.send(nil)
    end
  end
end

25.times { schedule_ch.send(nil) }
(SHUFFLED_LINKS.size / 3).times { ch.receive }


