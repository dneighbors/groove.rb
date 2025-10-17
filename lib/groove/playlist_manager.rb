# frozen_string_literal: true

require 'faraday'
require 'json'

module Groove
  # Manages Spotify playlist creation and track management
  class PlaylistManager
    class Error < Groove::Error; end
    class AuthenticationError < Error; end
    class PlaylistNotFoundError < Error; end
    class RateLimitError < Error; end
    class PlaylistError < Error; end

    SPOTIFY_API_BASE = 'https://api.spotify.com/v1'
    RATE_LIMIT_DELAY = 0.1 # 100ms between requests to stay under rate limits
    MAX_TRACKS_PER_REQUEST = 100

    attr_reader :access_token, :errors, :warnings, :operations

    def initialize(access_token)
      @access_token = access_token
      @errors = []
      @warnings = []
      @operations = []
      @last_request_time = 0
    end

    # Create a new playlist
    # @param name [String] Playlist name
    # @param description [String, nil] Optional playlist description
    # @param public [Boolean] Whether playlist should be public
    # @return [Hash, nil] Playlist data or nil on error
    def create_playlist(name:, description: nil, public: false)
      unless @access_token
        @errors << 'No access token provided'
        return nil
      end

      begin
        # First, get the current user's ID
        user_id = get_current_user_id
        return nil unless user_id

        # Create the playlist
        response = make_create_playlist_request(user_id, name, description, public)

        if response.success?
          playlist_data = parse_playlist_response(response.body)
          @operations << {
            type: :create_playlist,
            playlist_id: playlist_data[:id],
            name: name,
            success: true
          }
          playlist_data
        else
          handle_api_error(response, 'create playlist')
          nil
        end
      rescue StandardError => e
        @errors << "Create playlist error: #{e.message}"
        nil
      end
    end

    # Add tracks to a playlist
    # @param playlist_id [String] Spotify playlist ID
    # @param track_ids [Array<String>] Array of Spotify track IDs
    # @param skip_duplicates [Boolean] Whether to skip duplicate tracks
    # @return [Hash] Operation results
    def add_tracks(playlist_id:, track_ids:, skip_duplicates: true)
      unless @access_token
        @errors << 'No access token provided'
        return operation_result(false, 0, 0)
      end

      return operation_result(true, 0, 0) if track_ids.empty?

      begin
        # Get existing tracks if checking for duplicates
        existing_track_ids = if skip_duplicates
                               get_playlist_track_ids(playlist_id)
                             else
                               []
                             end

        # Filter out duplicates
        tracks_to_add = if skip_duplicates
                          track_ids.reject { |id| existing_track_ids.include?(id) }
                        else
                          track_ids
                        end

        skipped_count = track_ids.length - tracks_to_add.length
        @warnings << "Skipped #{skipped_count} duplicate tracks" if skipped_count.positive?

        # Add tracks in batches
        result = add_tracks_in_batches(playlist_id, tracks_to_add)
        added_count = result[:added]
        success = result[:success]

        @operations << {
          type: :add_tracks,
          playlist_id: playlist_id,
          added: added_count,
          skipped: skipped_count,
          success: success
        }

        operation_result(success, added_count, skipped_count)
      rescue StandardError => e
        @errors << "Add tracks error: #{e.message}"
        operation_result(false, 0, 0)
      end
    end

    # Get all track IDs from a playlist
    # @param playlist_id [String] Spotify playlist ID
    # @return [Array<String>] Array of track IDs
    def get_playlist_tracks(playlist_id:)
      get_playlist_track_ids(playlist_id)
    end

    # List user's playlists
    # @param limit [Integer, nil] Maximum number of playlists to return (nil for all)
    # @param filter [String, nil] Filter playlists by name (case-insensitive)
    # @return [Array<Hash>] Array of playlist hashes with id, name, tracks_total, public, owner
    def list_playlists(limit: nil, filter: nil)
      unless @access_token
        @errors << 'No access token provided'
        return []
      end

      begin
        playlists = fetch_all_playlists

        # Apply filter if provided
        if filter
          filter_lower = filter.downcase
          playlists = playlists.select { |p| p[:name].downcase.include?(filter_lower) }
        end

        # Apply limit if provided
        playlists = playlists.first(limit) if limit

        @operations << {
          type: :list_playlists,
          count: playlists.length,
          filtered: !filter.nil?,
          success: true
        }

        playlists
      rescue StandardError => e
        @errors << "List playlists error: #{e.message}"
        []
      end
    end

    # Get results summary
    # @return [Hash] Results with operations, errors, warnings
    def results
      {
        operations: @operations,
        errors: @errors,
        warnings: @warnings,
        success: @errors.empty?,
        total_operations: @operations.length
      }
    end

    private

    def get_current_user_id
      response = make_user_profile_request

      if response.success?
        response.body['id']
      else
        handle_api_error(response, 'get user profile')
        nil
      end
    end

    def make_user_profile_request
      rate_limit_delay

      connection = Faraday.new(url: "#{SPOTIFY_API_BASE}/me") do |conn|
        conn.response :json
        conn.adapter Faraday.default_adapter
      end

      connection.get do |req|
        req.headers['Authorization'] = "Bearer #{@access_token}"
      end
    end

    def make_create_playlist_request(user_id, name, description, is_public)
      rate_limit_delay

      connection = Faraday.new(url: "#{SPOTIFY_API_BASE}/users/#{user_id}/playlists") do |conn|
        conn.request :json
        conn.response :json
        conn.adapter Faraday.default_adapter
      end

      body = { name: name, public: is_public }
      body[:description] = description if description

      connection.post do |req|
        req.headers['Authorization'] = "Bearer #{@access_token}"
        req.body = body
      end
    end

    def get_playlist_track_ids(playlist_id)
      track_ids = []
      offset = 0
      limit = 100

      loop do
        response = make_get_playlist_tracks_request(playlist_id, limit, offset)

        break unless response.success?

        data = response.body
        items = data['items'] || []

        items.each do |item|
          track_id = item.dig('track', 'id')
          track_ids << track_id if track_id
        end

        # Check if there are more tracks
        total = data['total'] || 0
        break if offset + items.length >= total

        offset += limit
      end

      track_ids
    end

    def make_get_playlist_tracks_request(playlist_id, limit, offset)
      rate_limit_delay

      connection = Faraday.new(url: "#{SPOTIFY_API_BASE}/playlists/#{playlist_id}/tracks") do |conn|
        conn.response :json
        conn.adapter Faraday.default_adapter
      end

      connection.get do |req|
        req.params['limit'] = limit
        req.params['offset'] = offset
        req.headers['Authorization'] = "Bearer #{@access_token}"
      end
    end

    def add_tracks_in_batches(playlist_id, track_ids)
      added_count = 0
      has_errors = false

      track_ids.each_slice(MAX_TRACKS_PER_REQUEST) do |batch|
        track_uris = batch.map { |id| "spotify:track:#{id}" }
        response = make_add_tracks_request(playlist_id, track_uris)

        if response.success?
          added_count += batch.length
        else
          has_errors = true
          handle_api_error(response, 'add tracks')
          # Continue with next batch on error
        end
      end

      { added: added_count, success: !has_errors }
    end

    def make_add_tracks_request(playlist_id, track_uris)
      rate_limit_delay

      connection = Faraday.new(url: "#{SPOTIFY_API_BASE}/playlists/#{playlist_id}/tracks") do |conn|
        conn.request :json
        conn.response :json
        conn.adapter Faraday.default_adapter
      end

      connection.post do |req|
        req.headers['Authorization'] = "Bearer #{@access_token}"
        req.body = { uris: track_uris }
      end
    end

    def parse_playlist_response(body)
      {
        id: body['id'],
        name: body['name'],
        description: body['description'],
        public: body['public'],
        external_urls: body['external_urls'],
        href: body['href'],
        snapshot_id: body['snapshot_id']
      }
    end

    def operation_result(success, added, skipped)
      {
        success: success,
        added: added,
        skipped: skipped
      }
    end

    def fetch_all_playlists
      playlists = []
      offset = 0
      limit = 50 # Spotify maximum per page

      loop do
        response = make_get_playlists_request(limit, offset)

        unless response.success?
          handle_api_error(response, 'list playlists')
          break
        end

        data = response.body
        items = data['items'] || []

        items.each do |item|
          playlists << {
            id: item['id'],
            name: item['name'],
            tracks_total: item.dig('tracks', 'total') || 0,
            public: item['public'],
            owner: item.dig('owner', 'display_name') || item.dig('owner', 'id')
          }
        end

        # Check if there are more playlists
        next_url = data['next']
        break unless next_url

        offset += limit
      end

      playlists
    end

    def make_get_playlists_request(limit, offset)
      rate_limit_delay

      connection = Faraday.new(url: "#{SPOTIFY_API_BASE}/me/playlists") do |conn|
        conn.response :json
        conn.adapter Faraday.default_adapter
      end

      connection.get do |req|
        req.headers['Authorization'] = "Bearer #{@access_token}"
        req.params['limit'] = limit
        req.params['offset'] = offset
      end
    end

    def rate_limit_delay
      current_time = Time.now.to_f
      sleep_time = RATE_LIMIT_DELAY - (current_time - @last_request_time)
      sleep(sleep_time) if sleep_time.positive?
      @last_request_time = current_time
    end

    def handle_api_error(response, operation)
      case response.status
      when 401
        @errors << "Authentication failed for #{operation}: Invalid or expired access token"
      when 404
        @errors << "Playlist not found for #{operation}"
      when 429
        @errors << "Rate limit exceeded for #{operation}: Too many requests to Spotify API"
        @warnings << 'Consider implementing exponential backoff'
      when 400..499
        @errors << "Client error for #{operation}: #{response.status} - #{response.body}"
      when 500..599
        @errors << "Server error for #{operation}: #{response.status} - Spotify API is experiencing issues"
      else
        @errors << "Unexpected error for #{operation}: #{response.status} - #{response.body}"
      end
    end
  end
end
