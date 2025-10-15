# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groove::SpotifySearch do
  let(:access_token) { 'test_access_token' }
  let(:search) { described_class.new(access_token) }

  describe '#initialize' do
    it 'initializes with access token' do
      expect(search.access_token).to eq(access_token)
      expect(search.search_results).to eq([])
      expect(search.errors).to eq([])
      expect(search.warnings).to eq([])
    end
  end

  describe '#search_song' do
    let(:artist) { 'The Beatles' }
    let(:title) { 'Hey Jude' }

    context 'with valid access token' do
      before do
        stub_request(:get, "#{Groove::SpotifySearch::SEARCH_ENDPOINT}")
          .with(
            query: {
              q: 'artist:The%20Beatles track:Hey%20Jude',
              type: 'track',
              limit: 10
            },
            headers: { 'Authorization' => "Bearer #{access_token}" }
          )
          .to_return(
            status: 200,
            body: {
              tracks: {
                items: [
                  {
                    id: 'track123',
                    name: 'Hey Jude',
                    artists: [{ id: 'artist123', name: 'The Beatles' }],
                    album: {
                      id: 'album123',
                      name: 'The Beatles 1967-1970',
                      release_date: '1973-04-02'
                    },
                    duration_ms: 431_000,
                    popularity: 85,
                    preview_url: 'https://p.scdn.co/mp3-preview/123',
                    external_urls: { spotify: 'https://open.spotify.com/track/track123' }
                  }
                ]
              }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'searches for a song successfully' do
        result = search.search_song(artist, title)

        expect(result.results[:success]).to be true
        expect(result.results[:total_searches]).to eq(1)
        expect(result.results[:found_songs]).to eq(1)
        expect(result.results[:not_found_songs]).to eq(0)

        song_result = result.results[:search_results].first
        expect(song_result[:found]).to be true
        expect(song_result[:original_artist]).to eq(artist)
        expect(song_result[:original_title]).to eq(title)
        expect(song_result[:confidence]).to be > 0.8
        expect(song_result[:spotify_track][:name]).to eq('Hey Jude')
      end
    end

    context 'with no access token' do
      let(:search) { described_class.new(nil) }

      it 'returns error for missing access token' do
        result = search.search_song(artist, title)

        expect(result.results[:success]).to be false
        expect(result.results[:errors]).to include('No access token provided')
      end
    end

    context 'when song is not found' do
      before do
        stub_request(:get, "#{Groove::SpotifySearch::SEARCH_ENDPOINT}")
          .with(
            query: {
              q: 'artist:Unknown%20Artist track:Unknown%20Song',
              type: 'track',
              limit: 10
            },
            headers: { 'Authorization' => "Bearer #{access_token}" }
          )
          .to_return(
            status: 200,
            body: { tracks: { items: [] } }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'handles not found songs gracefully' do
        result = search.search_song('Unknown Artist', 'Unknown Song')

        expect(result.results[:success]).to be true
        expect(result.results[:found_songs]).to eq(0)
        expect(result.results[:not_found_songs]).to eq(1)

        song_result = result.results[:search_results].first
        expect(song_result[:found]).to be false
        expect(song_result[:confidence]).to eq(0.0)
        expect(song_result[:spotify_track]).to be_nil
      end
    end

    context 'with API errors' do
      before do
        stub_request(:get, "#{Groove::SpotifySearch::SEARCH_ENDPOINT}")
          .with(
            query: {
              q: 'artist:The%20Beatles track:Hey%20Jude',
              type: 'track',
              limit: 10
            },
            headers: { 'Authorization' => "Bearer #{access_token}" }
          )
          .to_return(status: 401, body: 'Unauthorized')
      end

      it 'handles authentication errors' do
        result = search.search_song(artist, title)

        expect(result.results[:success]).to be false
        expect(result.results[:errors]).to include('Authentication failed: Invalid or expired access token')
      end
    end

    context 'with rate limiting' do
      before do
        stub_request(:get, "#{Groove::SpotifySearch::SEARCH_ENDPOINT}")
          .with(
            query: {
              q: 'artist:The%20Beatles track:Hey%20Jude',
              type: 'track',
              limit: 10
            },
            headers: { 'Authorization' => "Bearer #{access_token}" }
          )
          .to_return(status: 429, body: 'Too Many Requests')
      end

      it 'handles rate limit errors' do
        result = search.search_song(artist, title)

        expect(result.results[:success]).to be false
        expect(result.results[:errors]).to include('Rate limit exceeded: Too many requests to Spotify API')
      end
    end
  end

  describe '#search_songs' do
    let(:songs) do
      [
        Groove::Models::Song.new(artist: 'The Beatles', title: 'Hey Jude'),
        Groove::Models::Song.new(artist: 'Queen', title: 'Bohemian Rhapsody')
      ]
    end

    before do
      stub_request(:get, "#{Groove::SpotifySearch::SEARCH_ENDPOINT}")
        .with(
          query: {
            q: 'artist:The%20Beatles track:Hey%20Jude',
            type: 'track',
            limit: 10
          },
          headers: { 'Authorization' => "Bearer #{access_token}" }
        )
        .to_return(
          status: 200,
          body: {
            tracks: {
              items: [
                {
                  id: 'track123',
                  name: 'Hey Jude',
                  artists: [{ id: 'artist123', name: 'The Beatles' }],
                  album: { id: 'album123', name: 'Test Album', release_date: '1970-01-01' },
                  duration_ms: 431_000,
                  popularity: 85,
                  preview_url: nil,
                  external_urls: { spotify: 'https://open.spotify.com/track/track123' }
                }
              ]
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      stub_request(:get, "#{Groove::SpotifySearch::SEARCH_ENDPOINT}")
        .with(
          query: {
            q: 'artist:Queen track:Bohemian%20Rhapsody',
            type: 'track',
            limit: 10
          },
          headers: { 'Authorization' => "Bearer #{access_token}" }
        )
        .to_return(
          status: 200,
          body: {
            tracks: {
              items: [
                {
                  id: 'track456',
                  name: 'Bohemian Rhapsody',
                  artists: [{ id: 'artist456', name: 'Queen' }],
                  album: { id: 'album456', name: 'A Night at the Opera', release_date: '1975-10-31' },
                  duration_ms: 355_000,
                  popularity: 90,
                  preview_url: nil,
                  external_urls: { spotify: 'https://open.spotify.com/track/track456' }
                }
              ]
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'searches for multiple songs' do
      result = search.search_songs(songs)

      expect(result.results[:success]).to be true
      expect(result.results[:total_searches]).to eq(2)
    end
  end

  describe 'search query building' do
    it 'cleans search terms correctly' do
      search.send(:clean_search_term, 'Artist feat. Other Artist')
      # This tests the private method indirectly through search_song
      expect(search.send(:clean_search_term, 'Artist feat. Other Artist')).to eq('Artist%20Other%20Artist')
    end

    it 'builds search query correctly' do
      query = search.send(:build_search_query, 'The Beatles', 'Hey Jude')
      expect(query).to eq('artist:The%20Beatles track:Hey%20Jude')
    end
  end

  describe 'match scoring' do
    let(:track) do
      {
        'name' => 'Hey Jude',
        'artists' => [{ 'name' => 'The Beatles' }],
        'popularity' => 85
      }
    end

    it 'calculates high confidence for exact matches' do
      score = search.send(:calculate_match_score, track, 'The Beatles', 'Hey Jude')
      expect(score).to be > 0.9
    end

    it 'calculates lower confidence for partial matches' do
      score = search.send(:calculate_match_score, track, 'Beatles', 'Jude')
      expect(score).to be > 0.5
      expect(score).to be < 0.9
    end

    it 'calculates low confidence for poor matches' do
      score = search.send(:calculate_match_score, track, 'Different Artist', 'Different Song')
      expect(score).to be < 0.3
    end
  end
end
