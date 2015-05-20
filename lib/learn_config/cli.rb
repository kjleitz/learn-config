module LearnConfig
  class CLI
    def ask_for_oauth_token
      puts <<-LONG
        To connect with the Learn web application, you will need to configure
        the Learn gem with an OAuth token. You can find yours on your profile
        page at: https://learn.co/your-github-username.

        Once you have it, please come back here and paste it in:
      LONG

      oauth_token = gets.chomp

      # TODO verify oauth token with learn interactor
    end
  end
end
