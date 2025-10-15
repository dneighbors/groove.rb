# frozen_string_literal: true

require "thor"
require "groove"

module Groove
  class CLI < Thor
    desc "auth SUBCOMMAND", "Authentication commands"
    subcommand "auth", Auth

    desc "version", "Show version information"
    def version
      say "Groove v#{Groove::VERSION}"
    end

    desc "help", "Show help information"
    def help
      say <<~HELP
        Groove - Sync text lists to Spotify playlists

        Commands:
          groove auth login     - Authenticate with Spotify
          groove auth logout    - Clear authentication
          groove auth status    - Check authentication status
          groove version        - Show version
          groove help          - Show this help

        For more information, visit: https://github.com/dneighbors/groove.rb
      HELP
    end
  end
end
