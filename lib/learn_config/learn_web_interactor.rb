require 'faraday'
require 'oj'

module LearnConfig
  class LearnWebInteractor
    attr_reader :token, :conn

    API_ROOT = 'https://learn.co/api/v1'
    ME_URL = '/users/me'

    def initialize(token)
      @token = token
      @conn = Faraday.new(url: API_ROOT) do |faraday|
        faraday.adapter  Faraday.default_adapter
      end
    end

    def me
      response = @conn.get do |req|
        req.url ME_URL
        req.headers['Authorization'] = "Bearer #{token}"
      end
      puts response

      Oj.load(response, symbol_keys: true)
    end
  end
end
