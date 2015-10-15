module Dgate
  class Session
    SETTING_FILE = ENV["HOME"] + "/.dgate"
    attr_reader :name, :token

    def initialize
      load_setting
    end

    def login?
      API::V1::Session.check(@name, @token)
    end

    def self.login(email, password)
      API::V1::Session.login(email, password)
    end

    def self.save(name, token)
      settings = {
          :name => name,
          :token => token
      }
      data = JSON.generate(settings)
      file = open(SETTING_FILE, "w+")
      file.print data
      file.close
    end

    def self.delete
      save('', '') # delete config values
    end

    private

    def load_setting
      return unless File.exist?(SETTING_FILE)
      file = open(SETTING_FILE)
      data = file.read
      file.close
      settings = JSON.parse(data)
      @name = settings['name']
      @token = settings['token']
    end

  end
end
