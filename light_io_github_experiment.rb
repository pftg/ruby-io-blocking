require 'lightio'
# apply monkey patch at beginning
LightIO::Monkey.patch_all!

require 'net/http'

host = 'github.com'
port = 443

start = Time.now

50.times.map do
  Thread.new do
    begin
      Net::HTTP.start(host, port, use_ssl: true) do |http|
        res = http.request_get('/ping')
        puts res.code
      end
    rescue => e
      puts e.message
    end
  end
end.each(&:join)

puts "#{Time.now - start} seconds"