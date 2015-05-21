require 'faraday'
require 'oj'

module LearnConfig
  class Setup
    attr_reader   :netrc, :args, :reset, :whoami

    def self.run(args)
      new(args).run
    end

    def initialize(args)
      @args   = args
      @netrc  = LearnConfig::NetrcInteractor.new
      @reset  = !!args.include?('--reset')
      @whoami = !!args.include?('--whoami')
    end

    def run
      if reset
        args.delete('--reset')
        confirm_and_reset!
      elsif whoami
        args.delete('--whoami')
        whoami?
      else
        setup_netrc
      end
    end

    private

    def whoami?
      _learn, token = netrc.read
      me = LearnConfig::LearnWebInteractor.new(token).me
      puts "Name:     #{me.full_name}"
      puts "Username: #{me.username}"
      puts "Email:    #{me.email}"

      exit
    end

    def confirm_and_reset!
      if confirm_reset?
        puts "CONFIRMED"
        netrc.delete!(machine: 'learn-config')
        netrc.delete!(machine: 'flatiron-push')

        setup_netrc
      end

      exit
    end

    def confirm_reset?
      puts "This will remove your existing Learn login configuration and reset.\n"
      print "Are you sure you want to do this? [yN]: "

      response = gets.chomp.downcase

      !!(response == 'yes' || response == 'y')
    end

    def setup_netrc
      setup_learn_config_machine
      setup_flatiron_push_config_machine
    end

    def setup_learn_config_machine
      login, password = netrc.read

      if (!login || !password) || !LearnConfig::LearnWebInteractor.new(password, silent_output: true).valid_token?
        github_username, _uid = netrc.read(machine: 'flatiron-push')
        oauth_token = LearnConfig::CLI.new(github_username).ask_for_oauth_token
        netrc.write(new_login: 'learn', new_password: oauth_token)
      end
    end

    def setup_flatiron_push_config_machine
      learn_login, token  = netrc.read(machine: 'learn-config')

      if (!learn_login || !token) || !LearnConfig::LearnWebInteractor.new(token, silent_output: true).valid_token?
        setup_learn_config_machine
      else
        ensure_correct_push_config(token)
      end
    end

    def ensure_correct_push_config(token)
      me              = LearnConfig::LearnWebInteractor.new(token).me
      github_username = me.username
      github_user_id  = me.github_uid

      netrc.write(
        machine: 'flatiron-push',
        new_login: github_username,
        new_password: github_user_id
      )
    end
  end
end
