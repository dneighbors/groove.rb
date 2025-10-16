# frozen_string_literal: true

require 'thor'

module Groove
  class Search < Thor
    desc 'song ARTIST TITLE', 'Search for a single song on Spotify'
    def song(artist, title)
      auth = Groove::Authentication.new(Groove::Configuration.new)

      unless auth.authenticated?
        say "❌ Not authenticated with Spotify. Run 'groove auth login' first."
        exit 1
      end

      search = Groove::SpotifySearch.new(auth.access_token)
      result = search.search_song(artist, title)

      if result.results[:success]
        song_result = result.results[:search_results].first

        if song_result[:found]
          track = song_result[:spotify_track]
          say "✅ Found: #{track[:name]} by #{track[:artists].map { |a| a[:name] }.join(', ')}"
          say "🎵 Album: #{track[:album][:name]} (#{track[:album][:release_date]})"
          say "⭐ Confidence: #{(song_result[:confidence] * 100).round(1)}%"
          say "🔗 Spotify: #{track[:external_urls][:spotify]}"

          say "🎧 Preview: #{track[:preview_url]}" if track[:preview_url]
        else
          say "❌ Song not found: #{artist} - #{title}"
          say "🔍 Search query: #{song_result[:search_query]}"
        end
      else
        say '❌ Search failed:'
        result.results[:errors].each { |error| say "  - #{error}" }
        exit 1
      end
    end

    desc 'file FILE_PATH', 'Search for all songs in a file on Spotify'
    def file(file_path)
      unless File.exist?(file_path)
        say "❌ File not found: #{file_path}"
        exit 1
      end

      auth = Groove::Authentication.new(Groove::Configuration.new)

      unless auth.authenticated?
        say "❌ Not authenticated with Spotify. Run 'groove auth login' first."
        exit 1
      end

      # Parse the file first
      parser = Groove::FileParser.new
      parse_result = parser.parse_file(file_path)

      unless parse_result.results[:success]
        say '❌ Failed to parse file:'
        parse_result.results[:errors].each { |error| say "  - #{error}" }
        exit 1
      end

      songs = parse_result.results[:songs]
      say "🔍 Searching for #{songs.length} songs on Spotify..."

      search = Groove::SpotifySearch.new(auth.access_token)
      result = search.search_songs(songs)

      if result.results[:success]
        say "\n📊 Search Results:"
        say "✅ Found: #{result.results[:found_songs]} songs"
        say "❌ Not found: #{result.results[:not_found_songs]} songs"

        say "\n🎵 Found Songs:"
        result.results[:search_results].each do |song_result|
          next unless song_result[:found]

          track = song_result[:spotify_track]
          confidence = (song_result[:confidence] * 100).round(1)
          say "  ✅ #{song_result[:original_artist]} - #{song_result[:original_title]}"
          say "     → #{track[:name]} by #{track[:artists].map { |a| a[:name] }.join(', ')} (#{confidence}%)"
        end

        say "\n❌ Not Found Songs:"
        result.results[:search_results].each do |song_result|
          say "  ❌ #{song_result[:original_artist]} - #{song_result[:original_title]}" unless song_result[:found]
        end

        if result.results[:warnings].any?
          say "\n⚠️  Warnings:"
          result.results[:warnings].each { |warning| say "  - #{warning}" }
        end
      else
        say '❌ Search failed:'
        result.results[:errors].each { |error| say "  - #{error}" }
        exit 1
      end
    end

    desc 'stats', 'Show search statistics and rate limit info'
    def stats
      auth = Groove::Authentication.new(Groove::Configuration.new)

      unless auth.authenticated?
        say "❌ Not authenticated with Spotify. Run 'groove auth login' first."
        exit 1
      end

      say '📊 Spotify Search Statistics:'
      say '🔑 Authentication: ✅ Authenticated'
      say "⏱️  Rate Limiting: #{Groove::SpotifySearch::RATE_LIMIT_DELAY}s between requests"
      say "🌐 API Endpoint: #{Groove::SpotifySearch::SEARCH_ENDPOINT}"
      say '📈 Search Limit: 10 results per query'
    end
  end
end
