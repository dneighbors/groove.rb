# frozen_string_literal: true

require 'thor'
require 'groove/authentication'
require 'groove/configuration'

module Groove
  class Auth < Thor
    desc 'login', 'Authenticate with Spotify'
    def login
      config = Configuration.new
      auth = Authentication.new(config)

      begin
        auth.login
      rescue Authentication::Error => e
        say "❌ Authentication failed: #{e.message}", :red
        exit 1
      end
    end

    desc 'logout', 'Clear authentication tokens'
    def logout
      config = Configuration.new
      auth = Authentication.new(config)
      auth.logout
    end

    desc 'status', 'Check authentication status'
    def status
      config = Configuration.new
      auth = Authentication.new(config)
      auth.status
    end
  end
end
