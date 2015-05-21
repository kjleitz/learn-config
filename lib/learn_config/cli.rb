module LearnConfig
  class CLI
    attr_reader   :github_username
    attr_accessor :token

    def initialize(github_username)
      @github_username = github_username
    end

    def ask_for_oauth_token
      puts <<-LONG
To connect with the Learn web application, you will need to configure
the Learn gem with an OAuth token. You can find yours on your profile
page at: https://learn.co/#{github_username ? github_username : 'your-github-username'}.

      LONG

      print('Once you have it, please come back here and paste it in: ')
      self.token = gets.chomp

      verify_token_or_ask_again!
    end

    private

    def verify_token_or_ask_again!
      if token_valid?
        token
      else
        ask_for_oauth_token
      end
    end

    def token_valid?
      learn = LearnConfig::LearnWebInteractor.new(token)
      learn.valid_token?
      # TODO: Make authed request. If 200, valid. If 401/422/500 invalid.
    end
  end
end
