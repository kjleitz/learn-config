require 'faraday'
require 'oj'

module LearnConfig
  class Setup
    attr_reader :netrc

    def self.run
      new.run
    end

    def initialize
      @netrc = LearnConfig::NetrcInteractor.new
    end

    def run
      setup_netrc
    end

    private

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
