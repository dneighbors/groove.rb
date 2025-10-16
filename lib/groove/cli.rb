# frozen_string_literal: true

require 'thor'

module Groove
  class CLI < Thor
    desc 'auth SUBCOMMAND', 'Authentication commands'
    subcommand 'auth', Auth

    desc 'parse SUBCOMMAND', 'File parsing commands'
    subcommand 'parse', Parse

    desc 'search SUBCOMMAND', 'Spotify search commands'
    subcommand 'search', Search

    desc 'playlist SUBCOMMAND', 'Playlist management commands'
    subcommand 'playlist', Playlist

    desc 'version', 'Show version information'
    def version
      say "Groove v#{Groove::VERSION}"
    end

    desc 'help', 'Show help information'
    def help
      say <<~HELP
        Groove - Sync text lists to Spotify playlists

        Commands:
          groove auth login           - Authenticate with Spotify
          groove auth logout          - Clear authentication
          groove auth status          - Check authentication status
          groove parse file           - Parse a single file containing songs
          groove parse files          - Parse multiple files containing songs
          groove parse validate       - Validate file format
          groove search song          - Search for a single song on Spotify
          groove search file          - Search for all songs in a file on Spotify
          groove search stats         - Show search statistics
          groove playlist create      - Create a new empty Spotify playlist
          groove playlist add         - Add songs to existing playlist (skips duplicates)
          groove playlist sync        - Create playlist and add songs in one step
          groove version              - Show version
          groove help                 - Show this help

        For more information, visit: https://github.com/dneighbors/groove.rb
      HELP
    end
  end
end
