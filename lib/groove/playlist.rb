# frozen_string_literal: true

require 'thor'

module Groove
  class Playlist < Thor
    desc 'create NAME', 'Create a new Spotify playlist'
    option :description, type: :string, desc: 'Playlist description'
    option :public, type: :boolean, default: false, desc: 'Make playlist public'
    def create(name)
      config = Configuration.new
      auth = Authentication.new(config)

      unless auth.authenticated?
        say '❌ Not authenticated. Run `groove auth login` first.', :red
        exit 1
      end

      manager = PlaylistManager.new(auth.access_token)
      playlist = manager.create_playlist(
        name: name,
        description: options[:description],
        public: options[:public]
      )

      if playlist
        say '✅ Playlist created successfully!', :green
        say "   Name: #{playlist[:name]}"
        say "   ID: #{playlist[:id]}"
        say "   Public: #{playlist[:public]}"
        say "   URL: #{playlist.dig(:external_urls, 'spotify')}" if playlist.dig(:external_urls, 'spotify')
      else
        say '❌ Failed to create playlist', :red
        manager.errors.each { |error| say "   Error: #{error}", :red }
        exit 1
      end
    end

    desc 'add PLAYLIST_ID FILE', 'Add songs from a file to a playlist (skips tracks already in the playlist)'
    option :skip_duplicates, type: :boolean, default: true, desc: 'Skip tracks that already exist in this playlist'
    option :format, type: :string, default: 'auto', desc: 'File format (csv, txt, json, auto)'
    def add(playlist_id, file_path)
      config = Configuration.new
      auth = Authentication.new(config)

      unless auth.authenticated?
        say '❌ Not authenticated. Run `groove auth login` first.', :red
        exit 1
      end

      unless File.exist?(file_path)
        say "❌ File not found: #{file_path}", :red
        exit 1
      end

      # Parse the file
      say 'Parsing file...', :yellow
      parser = FileParser.new
      songs = parser.parse_file(file_path).songs

      if songs.empty?
        say '❌ No songs found in file', :red
        exit 1
      end

      say "Found #{songs.length} songs", :green

      # Search for tracks on Spotify
      say 'Searching for tracks on Spotify...', :yellow
      search = SpotifySearch.new(auth.access_token)
      search.search_songs(songs)
      results = search.results

      track_ids = results[:search_results]
                  .select { |r| r[:found] }
                  .map { |r| r.dig(:spotify_track, :id) }
                  .compact

      say "Found #{track_ids.length} matching tracks on Spotify", :green

      if track_ids.empty?
        say '❌ No tracks found on Spotify', :red
        exit 1
      end

      # Add tracks to playlist
      say 'Adding tracks to playlist...', :yellow
      manager = PlaylistManager.new(auth.access_token)
      skip_duplicates = options[:skip_duplicates]
      skip_duplicates = config.class.config.playlist_duplicate_handling == 'skip' if skip_duplicates.nil?

      result = manager.add_tracks(
        playlist_id: playlist_id,
        track_ids: track_ids,
        skip_duplicates: skip_duplicates
      )

      if result[:success]
        say '✅ Tracks added successfully!', :green
        say "   Added: #{result[:added]} tracks"
        say "   Skipped: #{result[:skipped]} duplicates" if result[:skipped].positive?
      else
        say '❌ Failed to add tracks', :red
        manager.errors.each { |error| say "   Error: #{error}", :red }
        exit 1
      end
    end

    desc 'sync FILE', 'Create a new playlist and add songs from a file in one step'
    option :name, type: :string, desc: 'Playlist name (defaults to filename)'
    option :description, type: :string, desc: 'Playlist description'
    option :public, type: :boolean, default: false, desc: 'Make playlist public'
    option :skip_duplicates, type: :boolean, default: true, desc: 'Skip duplicate tracks (when re-running sync)'
    option :format, type: :string, default: 'auto', desc: 'File format (csv, txt, json, auto)'
    def sync(file_path)
      config = Configuration.new
      auth = Authentication.new(config)

      unless auth.authenticated?
        say '❌ Not authenticated. Run `groove auth login` first.', :red
        exit 1
      end

      unless File.exist?(file_path)
        say "❌ File not found: #{file_path}", :red
        exit 1
      end

      # Determine playlist name
      playlist_name = options[:name] || File.basename(file_path, '.*').gsub(/[_-]/, ' ').split.map(&:capitalize).join(' ')

      # Parse the file
      say 'Parsing file...', :yellow
      parser = FileParser.new
      songs = parser.parse_file(file_path).songs

      if songs.empty?
        say '❌ No songs found in file', :red
        exit 1
      end

      say "Found #{songs.length} songs", :green

      # Search for tracks on Spotify
      say 'Searching for tracks on Spotify...', :yellow
      search = SpotifySearch.new(auth.access_token)
      search.search_songs(songs)
      results = search.results

      track_ids = results[:search_results]
                  .select { |r| r[:found] }
                  .map { |r| r.dig(:spotify_track, :id) }
                  .compact

      say "Found #{track_ids.length} matching tracks on Spotify", :green

      if track_ids.empty?
        say '❌ No tracks found on Spotify', :red
        exit 1
      end

      # Create playlist
      say "Creating playlist '#{playlist_name}'...", :yellow
      manager = PlaylistManager.new(auth.access_token)
      playlist = manager.create_playlist(
        name: playlist_name,
        description: options[:description],
        public: options[:public]
      )

      unless playlist
        say '❌ Failed to create playlist', :red
        manager.errors.each { |error| say "   Error: #{error}", :red }
        exit 1
      end

      say '✅ Playlist created!', :green

      # Add tracks to playlist
      say 'Adding tracks to playlist...', :yellow
      result = manager.add_tracks(
        playlist_id: playlist[:id],
        track_ids: track_ids,
        skip_duplicates: options[:skip_duplicates]
      )

      if result[:success]
        say '✅ Sync complete!', :green
        say "   Playlist: #{playlist[:name]}"
        say "   Added: #{result[:added]} tracks"
        say "   Skipped: #{result[:skipped]} duplicates" if result[:skipped].positive?
        say "   URL: #{playlist.dig(:external_urls, 'spotify')}" if playlist.dig(:external_urls, 'spotify')
      else
        say '❌ Failed to add tracks', :red
        manager.errors.each { |error| say "   Error: #{error}", :red }
        exit 1
      end
    end
  end
end
