# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groove::Models::Song do
  describe '#initialize' do
    it 'creates a song with artist and title' do
      song = described_class.new(artist: 'The Beatles', title: 'Hey Jude')

      expect(song.artist).to eq('The Beatles')
      expect(song.title).to eq('Hey Jude')
      expect(song.confidence).to eq(1.0)
      expect(song.spotify_id).to be_nil
      expect(song.metadata).to eq({})
    end

    it 'strips whitespace from artist and title' do
      song = described_class.new(artist: '  The Beatles  ', title: '  Hey Jude  ')

      expect(song.artist).to eq('The Beatles')
      expect(song.title).to eq('Hey Jude')
    end

    it 'accepts additional parameters' do
      song = described_class.new(
        artist: 'The Beatles',
        title: 'Hey Jude',
        confidence: 0.8,
        spotify_id: 'abc123',
        metadata: { genre: 'rock' }
      )

      expect(song.confidence).to eq(0.8)
      expect(song.spotify_id).to eq('abc123')
      expect(song.metadata).to eq({ genre: 'rock' })
    end
  end

  describe '#to_s' do
    it 'returns formatted string' do
      song = described_class.new(artist: 'The Beatles', title: 'Hey Jude')
      expect(song.to_s).to eq('The Beatles - Hey Jude')
    end
  end

  describe '#==' do
    it 'compares songs by artist and title (case insensitive)' do
      song1 = described_class.new(artist: 'The Beatles', title: 'Hey Jude')
      song2 = described_class.new(artist: 'the beatles', title: 'HEY JUDE')

      expect(song1).to eq(song2)
    end

    it 'returns false for different songs' do
      song1 = described_class.new(artist: 'The Beatles', title: 'Hey Jude')
      song2 = described_class.new(artist: 'Queen', title: 'Bohemian Rhapsody')

      expect(song1).not_to eq(song2)
    end
  end

  describe '#valid?' do
    it 'returns true for valid song' do
      song = described_class.new(artist: 'The Beatles', title: 'Hey Jude')
      expect(song.valid?).to be true
    end

    it 'returns false for empty artist' do
      song = described_class.new(artist: '', title: 'Hey Jude')
      expect(song.valid?).to be false
    end

    it 'returns false for empty title' do
      song = described_class.new(artist: 'The Beatles', title: '')
      expect(song.valid?).to be false
    end

    it 'returns false for whitespace-only artist' do
      song = described_class.new(artist: '   ', title: 'Hey Jude')
      expect(song.valid?).to be false
    end
  end

  describe '#to_hash' do
    it 'converts song to hash' do
      song = described_class.new(
        artist: 'The Beatles',
        title: 'Hey Jude',
        confidence: 0.8,
        spotify_id: 'abc123',
        metadata: { genre: 'rock' }
      )

      hash = song.to_hash

      expect(hash).to eq({
                           artist: 'The Beatles',
                           title: 'Hey Jude',
                           confidence: 0.8,
                           spotify_id: 'abc123',
                           metadata: { genre: 'rock' }
                         })
    end
  end

  describe '.from_hash' do
    it 'creates song from hash with symbol keys' do
      hash = {
        artist: 'The Beatles',
        title: 'Hey Jude',
        confidence: 0.8,
        spotify_id: 'abc123',
        metadata: { genre: 'rock' }
      }

      song = described_class.from_hash(hash)

      expect(song.artist).to eq('The Beatles')
      expect(song.title).to eq('Hey Jude')
      expect(song.confidence).to eq(0.8)
      expect(song.spotify_id).to eq('abc123')
      expect(song.metadata).to eq({ genre: 'rock' })
    end

    it 'creates song from hash with string keys' do
      hash = {
        'artist' => 'The Beatles',
        'title' => 'Hey Jude',
        'confidence' => 0.8,
        'spotify_id' => 'abc123',
        'metadata' => { 'genre' => 'rock' }
      }

      song = described_class.from_hash(hash)

      expect(song.artist).to eq('The Beatles')
      expect(song.title).to eq('Hey Jude')
      expect(song.confidence).to eq(0.8)
      expect(song.spotify_id).to eq('abc123')
      expect(song.metadata).to eq({ 'genre' => 'rock' })
    end
  end
end
