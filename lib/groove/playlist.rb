# frozen_string_literal: true

require 'thor'
require 'json'

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
      say "Searching for tracks on Spotify (#{songs.length} songs)...", :yellow
      search = SpotifySearch.new(auth.access_token)

      songs.each_with_index do |song, index|
        search.search_song_internal(song.artist, song.title)
        say "  Progress: #{index + 1}/#{songs.length}", :cyan if ((index + 1) % 10).zero? || index == songs.length - 1
        sleep(0.1)
      end

      results = search.results
      found_tracks = results[:search_results].select { |r| r[:found] }
      not_found_tracks = results[:search_results].reject { |r| r[:found] }

      track_ids = found_tracks.map { |r| r.dig(:spotify_track, :id) }.compact

      say "Found #{track_ids.length} of #{songs.length} tracks on Spotify", :green

      if not_found_tracks.any?
        say "\n⚠️  Could not find #{not_found_tracks.length} tracks:", :yellow
        not_found_tracks.first(10).each do |track|
          say "   - #{track[:original_artist]} - #{track[:original_title]}", :yellow
        end
        say "   ... and #{not_found_tracks.length - 10} more" if not_found_tracks.length > 10
        say ''
      end

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
        say "   Added: #{result[:added]} of #{songs.length} tracks"
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
      say "Searching for tracks on Spotify (#{songs.length} songs)...", :yellow
      search = SpotifySearch.new(auth.access_token)

      songs.each_with_index do |song, index|
        search.search_song_internal(song.artist, song.title)
        say "  Progress: #{index + 1}/#{songs.length}", :cyan if ((index + 1) % 10).zero? || index == songs.length - 1
        sleep(0.1)
      end

      results = search.results
      found_tracks = results[:search_results].select { |r| r[:found] }
      not_found_tracks = results[:search_results].reject { |r| r[:found] }

      track_ids = found_tracks.map { |r| r.dig(:spotify_track, :id) }.compact

      say "Found #{track_ids.length} of #{songs.length} tracks on Spotify", :green

      if not_found_tracks.any?
        say "\n⚠️  Could not find #{not_found_tracks.length} tracks:", :yellow
        not_found_tracks.first(10).each do |track|
          say "   - #{track[:original_artist]} - #{track[:original_title]}", :yellow
        end
        say "   ... and #{not_found_tracks.length - 10} more" if not_found_tracks.length > 10
        say ''
      end

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
        say "   Added: #{result[:added]} of #{songs.length} tracks"
        say "   Skipped: #{result[:skipped]} duplicates" if result[:skipped].positive?
        say "   URL: #{playlist.dig(:external_urls, 'spotify')}" if playlist.dig(:external_urls, 'spotify')
      else
        say '❌ Failed to add tracks', :red
        manager.errors.each { |error| say "   Error: #{error}", :red }
        exit 1
      end
    end

    desc 'list', 'List your Spotify playlists with IDs'
    option :format, type: :string, default: 'table', desc: 'Output format (table or json)'
    option :filter, type: :string, desc: 'Filter playlists by name (case-insensitive)'
    def list
      config = Configuration.new
      auth = Authentication.new(config)

      unless auth.authenticated?
        say '❌ Not authenticated. Run `groove auth login` first.', :red
        exit 1
      end

      manager = PlaylistManager.new(auth.access_token)
      playlists = manager.list_playlists(filter: options[:filter])

      if manager.errors.any?
        say '❌ Failed to list playlists', :red
        manager.errors.each { |error| say "   Error: #{error}", :red }
        exit 1
      end

      if playlists.empty?
        if options[:filter]
          say "No playlists found matching '#{options[:filter]}'", :yellow
        else
          say 'You have no playlists yet. Create one with `groove playlist create NAME`', :yellow
        end
        return
      end

      if options[:format] == 'json'
        puts JSON.pretty_generate(playlists)
      else
        display_playlists_table(playlists)
      end
    end

    private

    def display_playlists_table(playlists)
      say ''
      say '📋 Your Spotify Playlists:', :cyan
      say ''

      # Calculate column widths with max limits to prevent overflow
      max_name_width = 50 # Limit name column to prevent overflow
      name_width = [playlists.map { |p| p[:name].length }.max, 20].max
      name_width = [name_width, max_name_width].min # Cap at max_name_width

      id_width = 22 # Standard Spotify ID length
      tracks_width = 7
      visibility_width = 10 # "🔒 Private" or "🌍 Public"

      max_owner_width = 20 # Limit owner column
      owner_width = [playlists.map { |p| p[:owner].length }.max, 15].max
      owner_width = [owner_width, max_owner_width].min

      # Print header
      header = format("  %-#{name_width}s  %-#{id_width}s  %#{tracks_width}s  %-#{visibility_width}s  %-#{owner_width}s",
                      'NAME', 'ID', 'TRACKS', 'VISIBILITY', 'OWNER')
      say header, :bold
      say "  #{'-' * (name_width + id_width + tracks_width + visibility_width + owner_width + 8)}"

      # Print playlists
      playlists.each do |playlist|
        visibility_icon = playlist[:public] ? '🌍 Public' : '🔒 Private'

        # Truncate long names/owners with ellipsis
        display_name = playlist[:name].length > name_width ? "#{playlist[:name][0...(name_width - 3)]}..." : playlist[:name]
        display_owner = playlist[:owner].length > owner_width ? "#{playlist[:owner][0...(owner_width - 3)]}..." : playlist[:owner]

        row = format("  %-#{name_width}s  %-#{id_width}s  %#{tracks_width}d  %-#{visibility_width}s  %-#{owner_width}s",
                     display_name,
                     playlist[:id],
                     playlist[:tracks_total],
                     visibility_icon,
                     display_owner)
        say row
      end

      say ''
      say "Total: #{playlists.length} playlist#{'s' if playlists.length != 1}", :green
      say ''
      say 'Use the ID to add songs: groove playlist add PLAYLIST_ID FILE', :yellow
      say ''
    end
  end
end
