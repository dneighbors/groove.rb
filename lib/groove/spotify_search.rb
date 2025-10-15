# frozen_string_literal: true

require 'faraday'
require 'json'
require 'cgi'

module Groove
  # Handles Spotify API search functionality for songs and artists
  class SpotifySearch
    class Error < Groove::Error; end
    class AuthenticationError < Error; end
    class RateLimitError < Error; end
    class SearchError < Error; end

    SPOTIFY_API_BASE = 'https://api.spotify.com/v1'.freeze
    SEARCH_ENDPOINT = "#{SPOTIFY_API_BASE}/search".freeze
    RATE_LIMIT_DELAY = 0.1 # 100ms between requests to stay under rate limits

    attr_reader :access_token, :search_results, :errors, :warnings

    def initialize(access_token)
      @access_token = access_token
      @search_results = []
      @errors = []
      @warnings = []
      @last_request_time = 0
    end

    # Search for a single song
    def search_song(artist, title)
      reset_state
      
      unless @access_token
        @errors << "No access token provided"
        return self
      end

      begin
        query = build_search_query(artist, title)
        response = make_search_request(query)
        
        if response.success?
          parse_search_results(response.body, artist, title)
        else
          handle_api_error(response)
        end
      rescue StandardError => e
        @errors << "Search error: #{e.message}"
      end

      self
    end

    # Search for multiple songs
    def search_songs(songs)
      reset_state
      
      songs.each do |song|
        search_song_internal(song.artist, song.title)
        sleep(RATE_LIMIT_DELAY) # Rate limiting
      end

      self
    end

    # Internal method to search a song without resetting state
    def search_song_internal(artist, title)
      unless @access_token
        @errors << "No access token provided"
        return
      end

      begin
        query = build_search_query(artist, title)
        response = make_search_request(query)
        
        if response.success?
          parse_search_results(response.body, artist, title)
        else
          handle_api_error(response)
        end
      rescue StandardError => e
        @errors << "Search error: #{e.message}"
      end
    end

    # Get search results
    def results
      {
        search_results: @search_results,
        errors: @errors,
        warnings: @warnings,
        success: @errors.empty?,
        total_searches: @search_results.length,
        found_songs: @search_results.count { |r| r[:found] },
        not_found_songs: @search_results.count { |r| !r[:found] }
      }
    end

    private

    def reset_state
      @search_results = []
      @errors = []
      @warnings = []
    end

    def build_search_query(artist, title)
      # Clean and normalize the search terms
      clean_artist = clean_search_term(artist)
      clean_title = clean_search_term(title)
      
      # Build query with artist and track
      "artist:#{clean_artist} track:#{clean_title}"
    end

    def clean_search_term(term)
      # Remove common words that might interfere with search
      cleaned = term.to_s.strip
        .gsub(/\b(feat\.?|featuring|ft\.?|ft|&|vs\.?|vs)\b/i, '')
        .gsub(/[^\w\s-]/, '')
        .gsub(/\s+/, ' ')
        .strip
      
      # Escape special characters for URL
      CGI.escape(cleaned).gsub('+', '%20')
    end

    def make_search_request(query)
      # Rate limiting
      current_time = Time.now.to_f
      sleep_time = RATE_LIMIT_DELAY - (current_time - @last_request_time)
      sleep(sleep_time) if sleep_time > 0
      @last_request_time = current_time

      connection = Faraday.new(url: SEARCH_ENDPOINT) do |conn|
        conn.request :json
        conn.response :json
        conn.adapter Faraday.default_adapter
      end

      connection.get do |req|
        req.params['q'] = query
        req.params['type'] = 'track'
        req.params['limit'] = 10
        req.headers['Authorization'] = "Bearer #{@access_token}"
      end
    end

    def parse_search_results(response_body, original_artist, original_title)
      tracks = response_body.dig('tracks', 'items') || []
      
      if tracks.empty?
        @search_results << {
          original_artist: original_artist,
          original_title: original_title,
          found: false,
          confidence: 0.0,
          spotify_track: nil,
          search_query: build_search_query(original_artist, original_title)
        }
        return
      end

      # Find the best match
      best_match = find_best_match(tracks, original_artist, original_title)
      
      @search_results << {
        original_artist: original_artist,
        original_title: original_title,
        found: true,
        confidence: best_match[:confidence],
        spotify_track: best_match[:track],
        search_query: build_search_query(original_artist, original_title),
        alternatives: tracks.first(3).map { |track| format_track_info(track) }
      }
    end

    def find_best_match(tracks, original_artist, original_title)
      best_match = nil
      best_score = 0.0

      tracks.each do |track|
        score = calculate_match_score(track, original_artist, original_title)
        
        if score > best_score
          best_score = score
          best_match = {
            track: format_track_info(track),
            confidence: score
          }
        end
      end

      best_match || { track: format_track_info(tracks.first), confidence: 0.1 }
    end

    def calculate_match_score(track, original_artist, original_title)
      track_name = track['name'].to_s.downcase
      track_artists = track['artists'].map { |a| a['name'].to_s.downcase }
      
      original_artist_clean = original_artist.to_s.downcase
      original_title_clean = original_title.to_s.downcase

      # Artist matching (weighted heavily)
      artist_score = calculate_artist_score(track_artists, original_artist_clean)
      
      # Title matching
      title_score = calculate_title_score(track_name, original_title_clean)
      
      # Popularity bonus (Spotify popularity 0-100)
      popularity_score = track['popularity'].to_f / 100.0 * 0.1
      
      # Combine scores
      (artist_score * 0.7) + (title_score * 0.3) + popularity_score
    end

    def calculate_artist_score(track_artists, original_artist)
      return 0.0 if track_artists.empty?
      
      # Exact match
      return 1.0 if track_artists.include?(original_artist)
      
      # Partial matches
      best_score = 0.0
      track_artists.each do |track_artist|
        # Check if original artist contains track artist or vice versa
        if track_artist.include?(original_artist) || original_artist.include?(track_artist)
          score = [track_artist.length, original_artist.length].min.to_f / 
                  [track_artist.length, original_artist.length].max
          best_score = [best_score, score].max
        end
        
        # Check for common words
        original_words = original_artist.split(/\s+/)
        track_words = track_artist.split(/\s+/)
        common_words = original_words & track_words
        
        if common_words.any?
          word_score = common_words.length.to_f / [original_words.length, track_words.length].max
          best_score = [best_score, word_score * 0.8].max
        end
      end
      
      best_score
    end

    def calculate_title_score(track_name, original_title)
      return 1.0 if track_name == original_title
      
      # Partial match
      if track_name.include?(original_title) || original_title.include?(track_name)
        return [track_name.length, original_title.length].min.to_f / 
               [track_name.length, original_title.length].max
      end
      
      # Word-based matching
      original_words = original_title.split(/\s+/)
      track_words = track_name.split(/\s+/)
      common_words = original_words & track_words
      
      return 0.0 if common_words.empty?
      
      common_words.length.to_f / [original_words.length, track_words.length].max
    end

    def format_track_info(track)
      {
        id: track['id'],
        name: track['name'],
        artists: track['artists'].map { |a| { id: a['id'], name: a['name'] } },
        album: {
          id: track['album']['id'],
          name: track['album']['name'],
          release_date: track['album']['release_date']
        },
        duration_ms: track['duration_ms'],
        popularity: track['popularity'],
        preview_url: track['preview_url'],
        external_urls: track['external_urls']
      }
    end

    def handle_api_error(response)
      case response.status
      when 401
        @errors << "Authentication failed: Invalid or expired access token"
      when 429
        @errors << "Rate limit exceeded: Too many requests to Spotify API"
        @warnings << "Consider implementing exponential backoff"
      when 400..499
        @errors << "Client error: #{response.status} - #{response.body}"
      when 500..599
        @errors << "Server error: #{response.status} - Spotify API is experiencing issues"
      else
        @errors << "Unexpected error: #{response.status} - #{response.body}"
      end
    end
  end
end
