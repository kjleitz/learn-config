module LearnConfig
  class CLI
    def self.ask_for_oauth_token(github_username)
      puts <<-LONG
        To connect with the Learn web application, you will need to configure
        the Learn gem with an OAuth token. You can find yours on your profile
        page at: https://learn.co/#{github_username ? github_username : 'your-github-username'}.

        Once you have it, please come back here and paste it in:
      LONG

      oauth_token = gets.chomp
      exit

      # TODO verify oauth token with learn interactor
    end
  end
end
