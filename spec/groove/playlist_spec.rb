# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require 'tempfile'

RSpec.describe Groove::Playlist do
  let(:playlist_command) { described_class.new }
  let(:access_token) { 'test_access_token' }
  let(:user_id) { 'test_user_123' }
  let(:playlist_id) { '2FMGjXrp1pbfIO4rCQhYaw' }

  # Setup for authenticated requests
  before do
    # Stub config using Dry::Configurable
    allow_any_instance_of(Groove::Configuration).to receive(:load_config) do
      Groove::Configuration.config.spotify_client_id = 'test_client_id'
      Groove::Configuration.config.spotify_client_secret = 'test_client_secret'
      Groove::Configuration.config.spotify_redirect_uri = 'http://localhost:8888/callback'
      Groove::Configuration.config.playlist_duplicate_handling = 'skip'
    end

    # Stub authentication
    allow_any_instance_of(Groove::Authentication).to receive(:authenticated?).and_return(true)
    allow_any_instance_of(Groove::Authentication).to receive(:access_token).and_return(access_token)

    # Stub Spotify API - user profile
    stub_request(:get, 'https://api.spotify.com/v1/me')
      .with(headers: { 'Authorization' => "Bearer #{access_token}" })
      .to_return(
        status: 200,
        body: { id: user_id }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe '#add' do
    let(:temp_file) { Tempfile.new(['songs', '.txt']) }

    before do
      # Write test song data to temp file
      temp_file.write("Anderson .Paak – Come Down\n")
      temp_file.write("Silk Sonic – Fly as Me\n")
      temp_file.write("Bruno Mars – Versace on the Floor\n")
      temp_file.close

      # Stub playlist tracks (for duplicate checking)
      stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
        .with(query: { limit: 100, offset: 0 })
        .to_return(
          status: 200,
          body: { items: [], total: 0 }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Stub search results
      allow_any_instance_of(Groove::SpotifySearch).to receive(:search_songs)
      allow_any_instance_of(Groove::SpotifySearch).to receive(:results).and_return(
        search_results: [
          { found: true, spotify_track: { id: 'track1', name: 'Come Down' } },
          { found: true, spotify_track: { id: 'track2', name: 'Fly as Me' } },
          { found: true, spotify_track: { id: 'track3', name: 'Versace on the Floor' } }
        ]
      )

      # Stub adding tracks to playlist
      stub_request(:post, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
        .to_return(
          status: 201,
          body: { snapshot_id: 'snap_123' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    after do
      temp_file.unlink
    end

    context 'file parsing regression test' do
      it 'calls FileParser#parse_file (not parse) and accesses .songs attribute' do
        # This test specifically prevents regression of the bug where we called parser.parse(file_path)
        # instead of parser.parse_file(file_path).songs
        # The bug was: NoMethodError: undefined method 'parse' for FileParser

        parser = instance_double(Groove::FileParser)
        songs = [
          Groove::Models::Song.new(artist: 'Anderson .Paak', title: 'Come Down'),
          Groove::Models::Song.new(artist: 'Silk Sonic', title: 'Fly as Me'),
          Groove::Models::Song.new(artist: 'Bruno Mars', title: 'Versace on the Floor')
        ]

        allow(Groove::FileParser).to receive(:new).and_return(parser)
        allow(parser).to receive(:parse_file).with(temp_file.path).and_return(parser)
        allow(parser).to receive(:songs).and_return(songs)

        # These expectations ensure we call the correct method chain:
        # 1. parse_file(file_path) - returns self
        # 2. .songs - returns the array of parsed songs
        expect(parser).to receive(:parse_file).with(temp_file.path).and_return(parser)
        expect(parser).to receive(:songs).and_return(songs)

        # Stub Spotify search API calls
        stub_request(:get, %r{api\.spotify\.com/v1/search})
          .to_return(
            status: 200,
            body: {
              tracks: {
                items: [
                  {
                    id: 'track1',
                    name: 'Come Down',
                    artists: [{ name: 'Anderson .Paak' }]
                  }
                ]
              }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        # Invoke the command
        playlist_command.options = { skip_duplicates: true, format: 'auto' }

        expect do
          playlist_command.add(playlist_id, temp_file.path)
        end.to output(/Found 3 songs/).to_stdout
      end
    end

    context 'when file does not exist' do
      it 'exits with error message' do
        playlist_command.options = { skip_duplicates: true, format: 'auto' }

        expect do
          playlist_command.add(playlist_id, 'nonexistent_file.txt')
        end.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end

    context 'when not authenticated' do
      before do
        allow_any_instance_of(Groove::Authentication).to receive(:authenticated?).and_return(false)
      end

      it 'exits with authentication error' do
        playlist_command.options = { skip_duplicates: true, format: 'auto' }

        expect do
          playlist_command.add(playlist_id, temp_file.path)
        end.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end
  end

  describe '#sync' do
    let(:temp_file) { Tempfile.new(['songs', '.txt']) }

    before do
      temp_file.write("Anderson .Paak – Come Down\n")
      temp_file.write("Silk Sonic – Fly as Me\n")
      temp_file.close

      # Stub search results
      allow_any_instance_of(Groove::SpotifySearch).to receive(:search_songs)
      allow_any_instance_of(Groove::SpotifySearch).to receive(:results).and_return(
        search_results: [
          { found: true, spotify_track: { id: 'track1', name: 'Come Down' } },
          { found: true, spotify_track: { id: 'track2', name: 'Fly as Me' } }
        ]
      )

      # Stub playlist creation
      stub_request(:post, "https://api.spotify.com/v1/users/#{user_id}/playlists")
        .to_return(
          status: 201,
          body: {
            id: playlist_id,
            name: 'Songs',
            description: nil,
            public: false,
            external_urls: { spotify: "https://open.spotify.com/playlist/#{playlist_id}" }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Stub playlist tracks (for duplicate checking)
      stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
        .with(query: { limit: 100, offset: 0 })
        .to_return(
          status: 200,
          body: { items: [], total: 0 }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Stub adding tracks
      stub_request(:post, "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks")
        .to_return(
          status: 201,
          body: { snapshot_id: 'snap_123' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    after do
      temp_file.unlink
    end

    context 'file parsing regression test' do
      it 'calls FileParser#parse_file (not parse) and accesses .songs attribute' do
        # This test specifically prevents regression of the bug where we called parser.parse(file_path)
        # instead of parser.parse_file(file_path).songs
        # The bug was: NoMethodError: undefined method 'parse' for FileParser

        parser = instance_double(Groove::FileParser)
        songs = [
          Groove::Models::Song.new(artist: 'Anderson .Paak', title: 'Come Down'),
          Groove::Models::Song.new(artist: 'Silk Sonic', title: 'Fly as Me')
        ]

        allow(Groove::FileParser).to receive(:new).and_return(parser)
        allow(parser).to receive(:parse_file).with(temp_file.path).and_return(parser)
        allow(parser).to receive(:songs).and_return(songs)

        # These expectations ensure we call the correct method chain:
        # 1. parse_file(file_path) - returns self
        # 2. .songs - returns the array of parsed songs
        expect(parser).to receive(:parse_file).with(temp_file.path).and_return(parser)
        expect(parser).to receive(:songs).and_return(songs)

        # Stub Spotify search API calls
        stub_request(:get, %r{api\.spotify\.com/v1/search})
          .to_return(
            status: 200,
            body: {
              tracks: {
                items: [
                  {
                    id: 'track1',
                    name: 'Come Down',
                    artists: [{ name: 'Anderson .Paak' }]
                  }
                ]
              }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        # Invoke the command
        playlist_command.options = { name: nil, description: nil, public: false, skip_duplicates: true, format: 'auto' }

        expect do
          playlist_command.sync(temp_file.path)
        end.to output(/Found 2 songs/).to_stdout
      end
    end

    context 'when file does not exist' do
      it 'exits with error message' do
        playlist_command.options = { name: nil, description: nil, public: false, skip_duplicates: true, format: 'auto' }

        expect do
          playlist_command.sync('nonexistent_file.txt')
        end.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end
  end

  describe '#create' do
    let(:playlist_name) { 'Test Playlist' }

    before do
      stub_request(:post, "https://api.spotify.com/v1/users/#{user_id}/playlists")
        .with(
          body: hash_including(name: playlist_name),
          headers: { 'Authorization' => "Bearer #{access_token}", 'Content-Type' => 'application/json' }
        )
        .to_return(
          status: 201,
          body: {
            id: playlist_id,
            name: playlist_name,
            description: nil,
            public: false,
            external_urls: { spotify: "https://open.spotify.com/playlist/#{playlist_id}" }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'creates a playlist successfully' do
      playlist_command.options = { description: nil, public: false }

      expect do
        playlist_command.create(playlist_name)
      end.to output(/✅ Playlist created successfully!/).to_stdout
    end

    context 'when not authenticated' do
      before do
        allow_any_instance_of(Groove::Authentication).to receive(:authenticated?).and_return(false)
      end

      it 'exits with authentication error' do
        playlist_command.options = { description: nil, public: false }

        expect do
          playlist_command.create(playlist_name)
        end.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end
  end
end
