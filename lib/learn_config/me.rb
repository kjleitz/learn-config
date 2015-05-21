require 'oj'

module LearnConfig
  class Me
    attr_accessor :response, :id, :first_name, :last_name, :full_name,
                  :username, :email, :github_gravatar, :github_uid, :data,
                  :silent_output

    def initialize(response, silent_output: false)
      @response      = response
      @silent_output = silent_output

      parse!
    end

    def parse!
      if response.status == 200
        self.data = Oj.load(response.body, symbol_keys: true)

        populate_attributes!
      elsif silent_output == false
        case response.status
        when 401
          puts "It seems your OAuth token is incorrect. Please re-run config with: learn reset"
          exit
        when 500
          puts "Something went wrong. Please try again."
          exit
        else
          puts "Something went wrong. Please try again."
          exit
        end
      end

      self
    end

    private

    def populate_attributes!
      data.each do |attribute, value|
        if !self.respond_to?(attribute)
          class << self
            attr_accessor attribute
          end
        end

        self.send("#{attribute}=", value)
      end
    end
  end
end
