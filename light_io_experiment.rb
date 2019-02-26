#  time ruby --jit light_io_experiment.rb

require 'lightio'
# apply monkey patch at beginning
LightIO::Monkey.patch_all!

require 'net/http'

require './test_data'

start = Time.now

SHUFFLED_LINKS.each_slice(5).with_index.map do |links, index|
  Thread.new do
    # puts index
    links.each do |link|
      begin
        LightIO::Timeout.timeout(5) do
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
end.each(&:join)

# 500.times.map do
#   Thread.new do
#     Net::HTTP.start(host, port, use_ssl: true) do |http|
#       res = http.request_get('/ping')
#       p res.code
#     end
#   end
# end.each(&:join)

puts "#{Time.now - start} seconds"