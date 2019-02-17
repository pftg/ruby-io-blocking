require "http/client"

response = HTTP::Client.get "https://github.com/ping"
puts response.status_code      # => 200
