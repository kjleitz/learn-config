require 'faraday'
require 'oj'

module LearnConfig
  class LearnWebInteractor
    attr_reader :token, :conn

    LEARN_URL = 'https://learn.co'
    API_ROOT  = '/api/v1'

    def initialize(token)
      @token = token
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

      case response.status
      when 200
        Oj.load(resonse.body, symbol_keys: true)
      when 401
        puts "It seems your OAuth token is incorrect. Please re-run config with: learn-config --reset"
      when 500
        puts "Something went wrong. Please try again."
        exit
      else
        puts "Something went wrong. Please try again."
        exit
      end
    end
  end
end
