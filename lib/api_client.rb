require 'faraday'
require 'json'

class ApiClient
  MAX_RETRIES = 3
  RETRY_DELAY = 1 # second

  def initialize(base_url, headers = {}, params = {})
    @connection = Faraday.new(url: base_url) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
      faraday.headers.merge!(headers)
      faraday.params.merge!(params)
    end
  end

  def get(path, params = {})
    retries = 0
    begin
      loop do
        response = @connection.get(path, params)
        
        if response.status == 429
          # Handle Rate Limiting
          retry_after = response.headers['Retry-After']&.to_i || (RETRY_DELAY * (2**retries))
          if retries < MAX_RETRIES
            retries += 1
            sleep(retry_after)
            next # Loop again
          end
        elsif response.status >= 500
          # Handle Transient Server Errors
          if retries < MAX_RETRIES
            retries += 1
            sleep(RETRY_DELAY * (2**retries))
            next # Loop again
          end
        end
        
        return response
      end
    rescue Faraday::Error => e
      # Handle Connection Errors
      if retries < MAX_RETRIES
        retries += 1
        sleep(RETRY_DELAY * (2**retries))
        retry
      end
      nil
    end
  end
end
