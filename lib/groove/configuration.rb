# frozen_string_literal: true

require 'dry-configurable'
require 'yaml'
require 'fileutils'

module Groove
  class Configuration
    extend Dry::Configurable

    setting :spotify_client_id, default: ''
    setting :spotify_client_secret, default: ''
    setting :spotify_redirect_uri, default: 'http://127.0.0.1:8080/callback'
    setting :debug, default: false
    setting :log_level, default: 'info'
    setting :playlist_public, default: false
    setting :playlist_duplicate_handling, default: 'skip'

    def initialize
      load_config
    end

    private

    def load_config
      config_path = File.expand_path('~/.config/groove/config.yaml')

      if File.exist?(config_path)
        config_data = YAML.load_file(config_path)

        self.class.config.spotify_client_id = config_data.dig('spotify', 'client_id') || ''
        self.class.config.spotify_client_secret = config_data.dig('spotify', 'client_secret') || ''
        self.class.config.spotify_redirect_uri = config_data.dig('spotify', 'redirect_uri') || 'http://localhost:8080/callback'
        self.class.config.debug = config_data.dig('app', 'debug') || false
        self.class.config.log_level = config_data.dig('logging', 'level') || 'info'
        self.class.config.playlist_public = config_data.dig('defaults', 'playlist_visibility') == 'public'
        self.class.config.playlist_duplicate_handling = config_data.dig('defaults', 'duplicate_handling') || 'skip'
      else
        # Use environment variables as fallback
        self.class.config.spotify_client_id = ENV['SPOTIFY_CLIENT_ID'] || ''
        self.class.config.spotify_client_secret = ENV['SPOTIFY_CLIENT_SECRET'] || ''
      end
    end
  end
end
