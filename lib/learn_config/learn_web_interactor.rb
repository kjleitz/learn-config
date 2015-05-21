require 'faraday'

module LearnConfig
  class LearnWebInteractor
    attr_reader :token, :conn, :silent_output

    LEARN_URL = 'https://learn.co'
    API_ROOT  = '/api/v1'

    def initialize(token, silent_output: false)
      @token = token
      @silent_output = silent_output
      @conn = Faraday.new(url: LEARN_URL) do |faraday|
        faraday.adapter Faraday.default_adapter
      end
    end

    def me_endpoint
      "#{API_ROOT}/users/me"
    end

    def me
      response = @conn.get do |req|
        req.url me_endpoint
        req.headers['Authorization'] = "Bearer #{token}"
      end

      LearnConfig::Me.new(response, silent_output: silent_output)
    end

    def valid_token?
      !!me.data
    end
  end
end
