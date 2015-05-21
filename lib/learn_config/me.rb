require 'oj'

module LearnConfig
  class Me
    attr_accessor :response, :id, :first_name, :last_name, :full_name,
                  :username, :email, :github_gravatar, :github_uid, :data

    def initialize(response)
      @response = response
      parse!
    end

    def parse!
      case response.status
      when 200
        self.data = Oj.load(resonse.body, symbol_keys: true)

        populate_attributes!
      when 401
        puts "It seems your OAuth token is incorrect. Please re-run config with: learn-config --reset"
        exit
      when 500
        puts "Something went wrong. Please try again."
        exit
      else
        puts "Something went wrong. Please try again."
        exit
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
