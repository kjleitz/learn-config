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

      if !login || !password
        github_username, _uid = netrc.read(machine: 'flatiron-push')
        oauth_token = LearnConfig::CLI.new(github_username).ask_for_oauth_token
      end
    end

    def setup_flatiron_push_config_machine
      login, password = netrc.read(machine: 'flatiron-push')
    end
  end
end