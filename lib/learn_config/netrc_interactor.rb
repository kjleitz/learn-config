require 'netrc'

module LearnConfig
  class NetrcInteractor
    attr_reader :login, :password, :netrc

    def initialize
      ensure_proper_permissions!
    end

    def read(machine: 'learn-config')
      @netrc = Netrc.read
      @login, @password = netrc[machine]
    end

    def write(machine:, new_login:, new_password:)
      netrc[machine] = new_login, new_password
      netrc.save
    end

    private

    def ensure_proper_permissions!
      system('chmod 0600 ~/.netrc')
    end
  end
end
