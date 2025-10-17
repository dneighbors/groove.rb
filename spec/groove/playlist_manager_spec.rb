# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

RSpec.describe Groove::PlaylistManager do
  let(:access_token) { 'test_access_token' }
  let(:manager) { described_class.new(access_token) }
  let(:user_id) { 'test_user_123' }
  let(:playlist_id) { 'playlist_123' }

  before do
    stub_request(:get, 'https://api.spotify.com/v1/me')
      .with(headers: { 'Authorization' => "Bearer #{access_token}" })
      .to_return(
        status: 200,
        body: { id: user_id }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe '#initialize' do
    it 'sets access token' do
      expect(manager.access_token).to eq(access_token)
    end

    it 'initializes empty errors array' do
      expect(manager.errors).to be_empty
    end

    it 'initializes empty warnings array' do
      expect(manager.warnings).to be_empty
    end

    it 'initializes empty operations array' do
      expect(manager.operations).to be_empty
    end
  end

  describe '#create_playlist' do
    context 'with valid parameters' do
      it 'creates a private playlist without description' do
        stub_request(:post, "https://api.spotify.com/v1/users/#{user_id}/playlists")
          .with(
            body: { name: 'My Playlist', public: false }.to_json,
            headers: { 'Authorization' => "Bearer #{access_token}", 'Content-Type' => 'application/json' }
          )
          .to_return(
            status: 201,
            body: {
              id: playlist_id,
              name: 'My Playlist',
              description: nil,
              public: false,
              external_urls: { spotify: 'https://open.spotify.com/playlist/playlist_123' },
              href: 'https://api.spotify.com/v1/playlists/playlist_123',
              snapshot_id: 'snap_123'
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = manager.create_playlist(name: 'My Playlist', public: false)

        expect(result).not_to be_nil
        expect(result[:id]).to eq(playlist_id)
        expect(result[:name]).to eq('My Playlist')
        expect(result[:public]).to be false
        expect(manager.operations.last[:type]).to eq(:create_playlist)
        expect(manager.errors).to be_empty
      end

      it 'creates a public playlist with description' do
        stub_request(:post, "https://api.spotify.com/v1/users/#{user_id}/playlists")
          .with(
            body: { name: 'Public Playlist', public: true, description: 'Test description' }.to_json,
            headers: { 'Authorization' => "Bearer #{access_token}", 'Content-Type' => 'application/json' }
          )
          .to_return(
            status: 201,
            body: {
              id: playlist_id,
              name: 'Public Playlist',
              description: 'Test description',
              public: true,
              external_urls: { spotify: 'https://open.spotify.com/playlist/playlist_123' },
              href: 'https://api.spotify.com/v1/playlists/playlist_123',
              snapshot_id: 'snap_123'
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = manager.create_playlist(name: 'Public Playlist', description: 'Test description', public: true)

        expect(result).not_to be_nil
        expect(result[:id]).to eq(playlist_id)
        expect(result[:public]).to be true
        expect(result[:description]).to eq('Test description')
      end
    end

    context 'with no access token' do
      let(:manager) { described_class.new(nil) }

      it 'returns nil and adds error' do
        result = manager.create_playlist(name: 'Test')

        expect(result).to be_nil
        expect(manager.errors).to include('No access token provided')
      end
    end

    context 'with authentication error' do
      it 'handles 401 error' do
        stub_request(:get, 'https://api.spotify.com/v1/me')
          .to_return(status: 401, body: {}.to_json)

        result = manager.create_playlist(name: 'Test')

        expect(result).to be_nil
        expect(manager.errors).to include(match(/Authentication failed/))
      end
    end

    context 'with API error' do
      it 'handles 500 server error' do
        stub_request(:post, "https://api.spotify.com/v1/users/#{user_id}/playlists")
          .to_return(status: 500, body: { error: 'Internal Server Error' }.to_json)

        result = manager.create_playlist(name: 'Test')

        expect(result).to be_nil
        expect(manager.errors).to include(match(/Server error/))
      end
    end
  end

  describe '#add_tracks' do
    let(:track_ids) { %w[track1 track2 track3] }

    before do
      # Stub get playlist tracks (for duplicate checking)
      stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
        .with(query: { limit: 100, offset: 0 })
        .to_return(
          status: 200,
          body: { items: [], total: 0 }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    context 'with valid track IDs' do
      it 'adds tracks to playlist' do
        stub_request(:post, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
          .with(
            body: { uris: ['spotify:track:track1', 'spotify:track:track2', 'spotify:track:track3'] }.to_json,
            headers: { 'Authorization' => "Bearer #{access_token}", 'Content-Type' => 'application/json' }
          )
          .to_return(
            status: 201,
            body: { snapshot_id: 'snap_456' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = manager.add_tracks(playlist_id: playlist_id, track_ids: track_ids, skip_duplicates: true)

        expect(result[:success]).to be true
        expect(result[:added]).to eq(3)
        expect(result[:skipped]).to eq(0)
        expect(manager.operations.last[:type]).to eq(:add_tracks)
      end

      it 'handles skip_duplicates = false' do
        stub_request(:post, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
          .to_return(
            status: 201,
            body: { snapshot_id: 'snap_456' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = manager.add_tracks(playlist_id: playlist_id, track_ids: track_ids, skip_duplicates: false)

        expect(result[:success]).to be true
        expect(result[:added]).to eq(3)
      end
    end

    context 'with duplicate tracks' do
      before do
        stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
          .with(query: { limit: 100, offset: 0 })
          .to_return(
            status: 200,
            body: {
              items: [
                { track: { id: 'track1', uri: 'spotify:track:track1' } }
              ],
              total: 1
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        stub_request(:post, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
          .to_return(
            status: 201,
            body: { snapshot_id: 'snap_456' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'skips duplicate tracks when skip_duplicates is true' do
        result = manager.add_tracks(playlist_id: playlist_id, track_ids: track_ids, skip_duplicates: true)

        expect(result[:success]).to be true
        expect(result[:added]).to eq(2) # track2 and track3
        expect(result[:skipped]).to eq(1) # track1
        expect(manager.warnings).to include('Skipped 1 duplicate tracks')
      end
    end

    context 'with empty track list' do
      it 'returns success with zero counts' do
        result = manager.add_tracks(playlist_id: playlist_id, track_ids: [], skip_duplicates: true)

        expect(result[:success]).to be true
        expect(result[:added]).to eq(0)
        expect(result[:skipped]).to eq(0)
      end
    end

    context 'with batch operations (>100 tracks)' do
      let(:large_track_list) { (1..150).map { |i| "track#{i}" } }

      before do
        stub_request(:post, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
          .to_return(
            status: 201,
            body: { snapshot_id: 'snap_456' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'chunks tracks into batches of 100' do
        result = manager.add_tracks(playlist_id: playlist_id, track_ids: large_track_list, skip_duplicates: false)

        expect(result[:success]).to be true
        expect(result[:added]).to eq(150)

        # Verify that exactly 2 requests were made (100 + 50)
        expect(
          a_request(:post, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
        ).to have_been_made.times(2)
      end
    end

    context 'with no access token' do
      let(:manager) { described_class.new(nil) }

      it 'returns failure and adds error' do
        result = manager.add_tracks(playlist_id: playlist_id, track_ids: track_ids)

        expect(result[:success]).to be false
        expect(manager.errors).to include('No access token provided')
      end
    end

    context 'with API errors' do
      before do
        stub_request(:post, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
          .to_return(status: 404, body: {}.to_json)
      end

      it 'handles 404 playlist not found' do
        result = manager.add_tracks(playlist_id: playlist_id, track_ids: track_ids, skip_duplicates: false)

        expect(result[:success]).to be false
        expect(manager.errors).to include(match(/Playlist not found/))
      end
    end

    context 'with rate limiting' do
      before do
        stub_request(:post, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
          .to_return(status: 429, body: {}.to_json)
      end

      it 'handles 429 rate limit error' do
        result = manager.add_tracks(playlist_id: playlist_id, track_ids: track_ids, skip_duplicates: false)

        expect(result[:success]).to be false
        expect(manager.errors).to include(match(/Rate limit exceeded/))
        expect(manager.warnings).to include(match(/exponential backoff/))
      end
    end
  end

  describe '#get_playlist_tracks' do
    context 'with tracks in playlist' do
      it 'returns all track IDs' do
        stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
          .with(query: { limit: 100, offset: 0 })
          .to_return(
            status: 200,
            body: {
              items: [
                { track: { id: 'track1' } },
                { track: { id: 'track2' } }
              ],
              total: 2
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        tracks = manager.get_playlist_tracks(playlist_id: playlist_id)

        expect(tracks).to eq(%w[track1 track2])
      end
    end

    context 'with pagination' do
      it 'fetches all pages' do
        stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
          .with(query: { limit: 100, offset: 0 })
          .to_return(
            status: 200,
            body: {
              items: Array.new(100) { |i| { track: { id: "track#{i}" } } },
              total: 150
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
          .with(query: { limit: 100, offset: 100 })
          .to_return(
            status: 200,
            body: {
              items: Array.new(50) { |i| { track: { id: "track#{i + 100}" } } },
              total: 150
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        tracks = manager.get_playlist_tracks(playlist_id: playlist_id)

        expect(tracks.length).to eq(150)
        expect(tracks.first).to eq('track0')
        expect(tracks.last).to eq('track149')
      end
    end

    context 'with empty playlist' do
      it 'returns empty array' do
        stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
          .with(query: { limit: 100, offset: 0 })
          .to_return(
            status: 200,
            body: { items: [], total: 0 }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        tracks = manager.get_playlist_tracks(playlist_id: playlist_id)

        expect(tracks).to be_empty
      end
    end
  end

  describe '#results' do
    it 'returns summary of operations' do
      results = manager.results

      expect(results).to include(
        :operations,
        :errors,
        :warnings,
        :success,
        :total_operations
      )
      expect(results[:success]).to be true
    end

    it 'reports failure when errors present' do
      manager.instance_variable_set(:@errors, ['Test error'])

      results = manager.results

      expect(results[:success]).to be false
      expect(results[:errors]).to include('Test error')
    end
  end

  describe 'rate limiting' do
    it 'respects rate limit delay between requests' do
      stub_request(:post, "https://api.spotify.com/v1/users/#{user_id}/playlists")
        .to_return(
          status: 201,
          body: { id: playlist_id, name: 'Test', public: false, external_urls: {}, href: '', snapshot_id: '' }.to_json
        )

      start_time = Time.now
      manager.create_playlist(name: 'Test1')
      manager.create_playlist(name: 'Test2')
      end_time = Time.now

      # Should have at least 100ms delay between requests (RATE_LIMIT_DELAY)
      expect(end_time - start_time).to be >= 0.1
    end
  end
end
