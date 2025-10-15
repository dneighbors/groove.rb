# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groove::Models::Artist do
  describe '#initialize' do
    it 'creates an artist with name' do
      artist = described_class.new(name: 'The Beatles')

      expect(artist.name).to eq('The Beatles')
      expect(artist.spotify_id).to be_nil
      expect(artist.metadata).to eq({})
    end

    it 'strips whitespace from name' do
      artist = described_class.new(name: '  The Beatles  ')
      expect(artist.name).to eq('The Beatles')
    end

    it 'accepts additional parameters' do
      artist = described_class.new(
        name: 'The Beatles',
        spotify_id: 'abc123',
        metadata: { genre: 'rock' }
      )

      expect(artist.spotify_id).to eq('abc123')
      expect(artist.metadata).to eq({ genre: 'rock' })
    end
  end

  describe '#to_s' do
    it 'returns artist name' do
      artist = described_class.new(name: 'The Beatles')
      expect(artist.to_s).to eq('The Beatles')
    end
  end

  describe '#==' do
    it 'compares artists by name (case insensitive)' do
      artist1 = described_class.new(name: 'The Beatles')
      artist2 = described_class.new(name: 'the beatles')

      expect(artist1).to eq(artist2)
    end

    it 'returns false for different artists' do
      artist1 = described_class.new(name: 'The Beatles')
      artist2 = described_class.new(name: 'Queen')

      expect(artist1).not_to eq(artist2)
    end
  end

  describe '#valid?' do
    it 'returns true for valid artist' do
      artist = described_class.new(name: 'The Beatles')
      expect(artist.valid?).to be true
    end

    it 'returns false for empty name' do
      artist = described_class.new(name: '')
      expect(artist.valid?).to be false
    end

    it 'returns false for whitespace-only name' do
      artist = described_class.new(name: '   ')
      expect(artist.valid?).to be false
    end
  end

  describe '#to_hash' do
    it 'converts artist to hash' do
      artist = described_class.new(
        name: 'The Beatles',
        spotify_id: 'abc123',
        metadata: { genre: 'rock' }
      )

      hash = artist.to_hash

      expect(hash).to eq({
                           name: 'The Beatles',
                           spotify_id: 'abc123',
                           metadata: { genre: 'rock' }
                         })
    end
  end

  describe '.from_hash' do
    it 'creates artist from hash with symbol keys' do
      hash = {
        name: 'The Beatles',
        spotify_id: 'abc123',
        metadata: { genre: 'rock' }
      }

      artist = described_class.from_hash(hash)

      expect(artist.name).to eq('The Beatles')
      expect(artist.spotify_id).to eq('abc123')
      expect(artist.metadata).to eq({ genre: 'rock' })
    end

    it 'creates artist from hash with string keys' do
      hash = {
        'name' => 'The Beatles',
        'spotify_id' => 'abc123',
        'metadata' => { 'genre' => 'rock' }
      }

      artist = described_class.from_hash(hash)

      expect(artist.name).to eq('The Beatles')
      expect(artist.spotify_id).to eq('abc123')
      expect(artist.metadata).to eq({ 'genre' => 'rock' })
    end
  end
end
