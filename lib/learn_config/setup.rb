module LearnConfig
  class Setup
    attr_reader   :netrc, :args, :reset, :whoami, :set_dir

    def self.run(args)
      new(args).run
    end

    def initialize(args)
      @args    = args
      @netrc   = LearnConfig::NetrcInteractor.new
      @reset   = !!args.include?('--reset')
      @whoami  = !!args.include?('--whoami')
      @set_dir = !!args.include?('--set-directory')
    end

    def run
      if reset
        args.delete('--reset')
        confirm_and_reset!
      elsif whoami
        args.delete('--whoami')
        check_config
        whoami?
      elsif set_dir
        args.delete('--set-directory')
        check_config
        set_directory!
      else
        check_config
      end
    end

    private

    def check_config
      setup_netrc
      setup_learn_directory
      setup_editor
    end

    def whoami?
      _learn, token = netrc.read
      me = LearnWeb::Client.new(token: token).me
      puts "Name:      #{me.full_name}"
      puts "Username:  #{me.username}"
      puts "Email:     #{me.email}"
      puts "Learn Dir: #{learn_directory}"

      exit
    end

    def learn_directory
      config_data = File.read(File.expand_path('~/.learn-config'))
      YAML.load(config_data)[:learn_directory]
    end

    def set_directory!
      path = ''

      while !path.start_with?('/')
        print "Enter the directory in which to store Learn lessons (/Users/#{ENV['USER']}/Development/code): "
        path = gets.chomp

        if path.start_with?('~')
          path = File.expand_path(path)
        elsif path == ''
          path = "/Users/#{ENV['USER']}/Development/code"
        elsif !path.start_with?('/')
          puts "Absolute paths only, please!"
        end
      end

      write_new_directory_data!(path)
    end

    def write_new_directory_data!(path)
      create_dir = true

      if !new_directory_exists?(path)
        print "#{path} doesn't exist. Create it? [Yn]: "
        response = gets.chomp.downcase

        if !['yes', 'y', ''].include?(response)
          create_dir = false
        end
      end

      if create_dir
        puts "CREATING DIR"
        FileUtils.mkdir_p(path)

        config_path = File.expand_path('~/.learn-config')
        existing_editor = YAML.load(File.read(config_path))[:editor]
        puts "EXISTING EDITOR"
        puts existing_editor
        data = YAML.dump({ learn_directory: path, editor: existing_editor })

        File.write(config_path, data)
      else
        set_directory!
      end
    end

    def new_directory_exists?(path)
      File.exists?(path)
    end

    def confirm_and_reset!
      if confirm_reset?
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

    def setup_learn_directory
      if !config_file?
        write_default_config!
      end
    end

    def setup_editor
      if !config_file?
        write_defalt_config!
      end
    end

    def config_file?
      path = File.expand_path('~/.learn-config')
      File.exists?(path) && has_yaml?(path)
    end

    def has_yaml?(file_path)
      !!YAML.load(File.read(file_path)) && valid_config_yaml?(file_path)
    end

    def valid_config_yaml?(path)
      yaml       = YAML.load(File.read(path))
      dir        = !!yaml[:learn_directory]
      dir_path   = yaml[:learn_directory]
      dir_exists = dir && File.exists?(dir_path)
      editor     = !!yaml[:editor]

      if !dir_exists
        puts "It seems like your Learn directory isn't quite right. Let's fix that."
        set_directory!
      end

      dir && dir_exists && editor
    end

    def write_default_config!
      learn_dir = File.expand_path('~/Development/code')
      config_path = File.expand_path('~/.learn-config')

      ensure_default_dir_exists!(learn_dir)
      ensure_config_file_exists!(config_path)

      data = YAML.dump({ learn_directory: learn_dir, editor: "subl" })

      File.write(config_path, data)
    end

    def ensure_default_dir_exists!(learn_dir)
      FileUtils.mkdir_p(learn_dir)
    end

    def ensure_config_file_exists!(config_path)
      FileUtils.touch(config_path)
    end

    def setup_learn_config_machine
      login, password = netrc.read

      if (!login || !password) || !LearnWeb::Client.new(token: password, silent_output: true).valid_token?
        github_username, _uid = netrc.read(machine: 'flatiron-push')
        oauth_token = LearnConfig::CLI.new(github_username).ask_for_oauth_token
        netrc.write(new_login: 'learn', new_password: oauth_token)
      end
    end

    def setup_flatiron_push_config_machine
      learn_login, token  = netrc.read(machine: 'learn-config')

      if (!learn_login || !token) || !LearnWeb::Client.new(token: token, silent_output: true).valid_token?
        setup_learn_config_machine
      else
        ensure_correct_push_config(token)
      end
    end

    def ensure_correct_push_config(token)
      me              = LearnWeb::Client.new(token: token).me
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
