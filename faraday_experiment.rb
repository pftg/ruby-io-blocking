require 'async/reactor'
require 'async/http/faraday'
require 'async/http/response'
require 'async/http/server'
require 'async/http/url_endpoint'

Faraday.default_adapter = :async_http

require './test_data'
require 'timeout'

def faraday_example
  Async::Reactor.run do |task|
    # Make a pool with two workers:

    SHUFFLED_LINKS.first(25).each_slice(5).map do |links|
      task.async do |_subtask|
        # task.with_timeout(5) do
        links.each do |link|
          begin
            # TODO: Need to figure out Timeout issue for this case:
            #       [more details](https://cl.ly/ffa804b1204d/Image%202019-02-17%20at%2011.34.25.png)
            # Timeout.timeout(5) do
            response = Faraday.get link, request: { timeout: 5 }
            # puts response.status
            # end
          rescue => e
            puts "Link with error: #{link}"
            puts e.message

            nil
          end
        end
        # rescue Async::TimeoutError
        #   puts "I timed out!"
        # end
      end
    end

  end
end


start = Time.now

faraday_example

puts "#{Time.now - start} seconds"